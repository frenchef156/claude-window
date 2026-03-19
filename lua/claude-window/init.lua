local M = {}

local function setup_input_keymap(terminal_buf)
	local job_id = vim.b[terminal_buf].terminal_job_id
	if not job_id then
		return
	end

	vim.api.nvim_create_autocmd("TermEnter", {
		buffer = terminal_buf,
		callback = function()
			local win = vim.api.nvim_get_current_win()
			local width = vim.api.nvim_win_get_width(win)
			vim.api.nvim_win_set_width(win, width + 1)
			vim.defer_fn(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_set_width(win, width)
				end
			end, 10)
		end,
	})

	vim.keymap.set("n", "<leader>i", function()
		local input_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = input_buf })
		vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = input_buf })

		local screen_width = vim.api.nvim_get_option("columns")
		local screen_height = vim.api.nvim_get_option("lines")
		local win_width = math.floor(screen_width * 0.6)
		local win_height = math.floor(screen_height * 0.2)
		local row = math.floor(screen_height * 0.75)
		local col = math.floor((screen_width - win_width) / 2)

		local input_win = vim.api.nvim_open_win(input_buf, true, {
			relative = "editor",
			width = win_width,
			height = win_height,
			row = row,
			col = col,
			border = "single",
			title = "Claude Input (Enter: send, S-Enter: newline, Esc: cancel)",
			title_pos = "left",
		})

		vim.cmd("startinsert")

		vim.keymap.set("i", "<S-CR>", function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>o", true, false, true), "n", false)
		end, { buffer = input_buf })

		vim.keymap.set("i", "<Esc>", function()
			vim.cmd("stopinsert")
			if vim.api.nvim_win_is_valid(input_win) then
				vim.api.nvim_win_close(input_win, true)
			end
		end, { buffer = input_buf })

		vim.keymap.set("i", "<CR>", function()
			vim.cmd("stopinsert")
			local lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
			local text = table.concat(lines, "\n")
			vim.api.nvim_chan_send(job_id, text)
			-- Delay so \r arrives as a separate single-byte read on stdin,
			-- which Ink interprets as an Enter keypress (submit) rather than pasted text
			vim.defer_fn(function()
				vim.api.nvim_chan_send(job_id, "\r")
			end, 100)
			if vim.api.nvim_win_is_valid(input_win) then
				vim.api.nvim_win_close(input_win, true)
			end
		end, { buffer = input_buf })
	end, { buffer = terminal_buf, desc = "Open Claude input window" })
end

function M.setup()
	local claude_command_name = "ClaudeTerminal"
	local claude_split_right = "split_right"
	local claude_split_left = "split_left"
	local claude_split_bottom = "split_bottom"
	local claude_split_top = "split_top"
	local claude_floating = "floating"
	local claude_split_types = { claude_split_right, claude_split_left, claude_split_bottom, claude_split_top, claude_floating }

	vim.api.nvim_create_user_command(
		claude_command_name,
		function(opts)
			local split_type = opts.args
			if not vim.tbl_contains(claude_split_types, split_type) then
				split_type = claude_floating -- Default to floating if not specified or invalid
			end
			local buf_name = "__claude-terminal__"

			-- Check if we're currently in the claude terminal - if so, close it
			local current_buf_name = vim.api.nvim_buf_get_name(0)
			if current_buf_name:find(buf_name, 1, true) then
				vim.cmd("close")
				return
			end

			-- Check if claude terminal buffer exists and if it's currently visible
			local existing_buf = nil
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				local buf_name_actual = vim.api.nvim_buf_get_name(buf)
				if buf_name_actual:find(buf_name, 1, true) then
					existing_buf = buf
					-- Check if this buffer is visible in any window
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_buf(win) == buf then
							vim.api.nvim_set_current_win(win)
							return -- Just switch to the existing window
						end
					end
					break
				end
			end

			-- Create window and show buffer
			if split_type == claude_floating then
				local screenWidth = vim.api.nvim_get_option("columns")
				local screenHeight = vim.api.nvim_get_option("lines")
				local buf_for_window = existing_buf or vim.api.nvim_create_buf(false, true)
				local win = vim.api.nvim_open_win(buf_for_window, true, {
					relative = "editor",
					height = math.floor(screenHeight * 0.7),
					width = math.floor(screenWidth * 0.7),
					row = math.floor(screenHeight * 0.15),
					col = math.floor(screenWidth * 0.15),
					border = "single",
					title = "Claude Terminal",
					title_pos = "left",
				})
				if not existing_buf then
					-- Ensure we're focused on the floating window
					vim.api.nvim_set_current_win(win)
					vim.cmd("terminal claude")
					vim.cmd("file " .. buf_name)
					setup_input_keymap(vim.api.nvim_get_current_buf())
				end
			else
				-- Handle split types
				if split_type == claude_split_right then
					vim.cmd("rightbelow vsplit")
				elseif split_type == claude_split_left then
					vim.cmd("leftabove vsplit")
				elseif split_type == claude_split_bottom then
					vim.cmd("rightbelow split")
				elseif split_type == claude_split_top then
					vim.cmd("leftabove split")
				end

				-- Show existing buffer or create new terminal
				if existing_buf then
					vim.cmd("buffer " .. existing_buf)
				else
					vim.cmd("terminal claude")
					vim.cmd("file " .. buf_name)
					setup_input_keymap(vim.api.nvim_get_current_buf())
				end
			end
		end,
		{
			nargs = "?",
			complete = function()
				return claude_split_types
			end,
		}
	)

	-- vim.keymap.set("n", "<F3>", ":" .. claude_command_name .. " " .. claude_split_right .. "<CR>", { desc = "Open Claude terminal in floating window" })
	-- vim.keymap.set("n", "<S-F3>", ":" .. claude_command_name .. "<CR>", { desc = "Open Claude terminal in floating window" })
end

return M

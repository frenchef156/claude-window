## claude-window

A tiny Neovim plugin for quickly showing and managing a Claude code terminal window inside Neovim. It opens a `terminal` running the `claude` CLI in a floating window or in a split, focuses an existing window if it already exists, and hides the window if you are currently inside it.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)

###### This Neovim Claude code plugin was developed using claude code running in a Neovim terminal. Recursion is fun.

https://github.com/user-attachments/assets/b9eed663-ce68-4dce-9e15-8c5619335542

### Features
- **Single command**: `:ClaudeTerminal [split_right|split_left|split_bottom|split_top|floating]`
- **Smart focus**: Jumps to an existing Claude terminal window if already open
- **Context-aware hide**: Calling the command from inside the Claude terminal window hides it
- **Floating or splits**: Default floating window with border and title; or open in a split
- **Input window**: Compose multi-line input in a floating scratch buffer, then send it to Claude with a single keypress

### Requirements
- Neovim with Lua support
- The `claude` CLI available in your `$PATH`

## Installation (lazy.nvim)

Add this plugin to your Lazy spec and call `setup()`:

```lua
{
  -- If hosted on GitHub under your account
  "frenchef156/claude-window",
  config = function()
    require("claude-window").setup()

    -- Suggested keymaps (from the plugin source)
    -- vim.keymap.set("n", "<F3>", ":ClaudeTerminal split_right<CR>", { desc = "Open Claude terminal in right split" })
    -- vim.keymap.set("n", "<S-F3>", ":ClaudeTerminal<CR>", { desc = "Open Claude terminal in floating window" })
  end,
}
```

## Usage

- **Command**: `:ClaudeTerminal [mode]`
  - **modes**: `floating` (default), `split_right`, `split_left`, `split_bottom`, `split_top`
- Re-running the command while focused inside the Claude terminal window will hide it.
- If the window exists elsewhere, running the command will focus it instead of creating a new one.

### Examples

```vim
:ClaudeTerminal           " open floating window (default)
:ClaudeTerminal floating  " explicitly open floating window
:ClaudeTerminal split_right
:ClaudeTerminal split_left
:ClaudeTerminal split_bottom
:ClaudeTerminal split_top
```

### Input window

Neovim's terminal mode can be error-prone when working with Claude. If you switch to another application and return to Neovim, you might forget you're in terminal mode inside the Claude buffer — any keystrokes (like `:s/aaa/bbb/g` or `dd`) go straight to Claude as an accidental message. The input window solves this by letting you stay in **normal mode** by default. You only enter insert mode inside a short-lived floating scratch buffer, compose your prompt there, and press `<CR>` to send it. This way you get full Vim editing capabilities while composing, avoid accidental input, and keep your terminal buffer in normal mode at all times.

Press `<leader>i` from normal mode in the Claude terminal buffer to open the input window.

| Key | Mode | Action |
|---|---|---|
| `<leader>i` | Normal (terminal buffer) | Open the input window |
| `<CR>` | Insert (input window) | Send text to Claude and close |
| `<S-CR>` | Insert (input window) | Insert a newline (multi-line input) |
| `<Esc>` | Insert (input window) | Cancel and close without sending |

## Suggested keymaps

These mirror the two commented mappings included in the source and are a good starting point. Feel free to adjust to your own preferences.

```lua
-- Open Claude terminal in a right split
vim.keymap.set("n", "<F3>", ":ClaudeTerminal split_right<CR>", { desc = "Open Claude terminal in right split" })

-- Open Claude terminal in a floating window (default behavior)
vim.keymap.set("n", "<S-F3>", ":ClaudeTerminal<CR>", { desc = "Open Claude terminal in floating window" })
```

## Behavior details

- The terminal buffer is named `__claude-terminal__`.
- Floating window defaults to ~70% of the editor size with a single border and title.
- The input window is ~60% width, ~20% height, positioned toward the bottom of the screen.
- Splits use Vim's built-in `vsplit`/`split` with directional placement.

## License

See `LICENSE` in this repository.

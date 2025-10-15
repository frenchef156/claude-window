## claude-window

A tiny Neovim plugin for quickly showing and managing a Claude code terminal window inside Neovim. It opens a `terminal` running the `claude` CLI in a floating window or in a split, focuses an existing window if it already exists, and hides the window if you are currently inside it.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)

###### This Neovim Claude code plugin was developed using claude code running in a Neovim terminal. Recursion is fun.

### Features
- **Single command**: `:ClaudeTerminal [split_right|split_left|split_bottom|split_top|floating]`
- **Smart focus**: Jumps to an existing Claude terminal window if already open
- **Context-aware hide**: Calling the command from inside the Claude terminal window hides it
- **Floating or splits**: Default floating window with border and title; or open in a split

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
- Splits use Vim's built-in `vsplit`/`split` with directional placement.

## License

See `LICENSE` in this repository.



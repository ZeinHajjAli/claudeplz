# claudeplz

A minimal Neovim plugin that embeds a [Claude Code](https://code.claude.com/docs/en/overview) terminal session directly in your editor and lets you send context from your buffers - files, selections, and LSP diagnostics - with a single keymap.

## Requirements

- Neovim >= 0.8
- [`claude`](https://claude.ai/code) CLI installed and available in `$PATH`

## Installation

**lazy.nvim**
```lua
{
  "zeinhajjali/claudeplz",
  config = function()
    require("claudeplz").setup()
  end,
}
```

## Setup

Call `setup()` with optional overrides. All options shown below are their defaults:

```lua
require("claudeplz").setup({
  auto_reload = true,   -- auto-reload buffers when Claude writes to disk
  mappings = {
    split      = '<leader>c"',  -- open Claude in a horizontal split
    vsplit     = "<leader>c%",  -- open Claude in a vertical split
    send_file  = "<leader>cf",  -- send the current file
    send_sel   = "<leader>cs",  -- send the visual selection  (visual mode)
    send_diag  = "<leader>cd",  -- send LSP diagnostics for the current buffer
  },
})
```

Set any mapping to `false` to disable it:

```lua
require("claudeplz").setup({
  mappings = {
    split = false,  -- don't bind the horizontal split key
  },
})
```

## Usage

### Opening a session

| Keymap | Action |
|--------|--------|
| `<leader>c"` | Open Claude in a horizontal split |
| `<leader>c%` | Open Claude in a vertical split |

Each Neovim tab gets its own Claude session. Triggering the keymap again on a tab that already has a session focuses the existing window instead of opening a new one.

### Sending context

| Keymap | Mode | What gets sent |
|--------|------|----------------|
| `<leader>cf` | Normal | The entire current file, wrapped in a fenced code block |
| `<leader>cs` | Visual | The selected text, wrapped in a fenced code block |
| `<leader>cd` | Normal | All LSP diagnostics for the current buffer |

Context is sent directly into the active Claude session on the current tab. If no session is open, you'll get a warning notification.

### Auto-reload

With `auto_reload = true` (default), Neovim's `autoread` is enabled and `checktime` is triggered on common events (`BufEnter`, `FocusGained`, `TermLeave`, etc.). This means files edited by Claude are automatically refreshed in your buffers without any manual intervention.

## Lua API

You can also send text programmatically:

```lua
require("claudeplz").send("explain this codebase")
```

## Health check

Run `:checkhealth claudeplz` to verify your setup — it checks the Neovim version, that the `claude` binary is reachable, and that the plugin is configured correctly.

## License

MIT

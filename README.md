# claudeplz

A minimal Neovim plugin that embeds a [Claude Code](https://claude.ai/code) terminal session directly in your editor and lets you send context from your buffers - files, selections, LSP diagnostics, and git diffs - with a single keymap.

## Requirements

- Neovim >= 0.8
- [`claude`](https://code.claude.com/docs/en/overview) CLI installed and available in `$PATH`

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
  cli_args = {},        -- extra arguments passed to the `claude` CLI
  mappings = {
    split          = '<leader>c"',   -- open Claude in a horizontal split
    vsplit         = "<leader>c%",   -- open Claude in a vertical split
    send_file      = "<leader>cf",   -- send the current file
    send_sel       = "<leader>cs",   -- send the visual selection  (visual mode)
    send_diag      = "<leader>cd",   -- send LSP diagnostics for the current buffer
    send_diff      = "<leader>cD",   -- send the full git diff (all staged/unstaged changes)
    send_file_diff = "<leader>cdd",  -- send the git diff for the current file only
  },
})
```

Pass extra flags to the `claude` CLI (e.g. for automated/demo environments):

```lua
require("claudeplz").setup({
  cli_args = { "--dangerously-skip-permissions" },
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
| `<leader>cD` | Normal | The full `git diff` (all staged and unstaged changes) |
| `<leader>cdd` | Normal | The `git diff` for the current file only |

Context is sent directly into the active Claude session on the current tab. If no session is open, you'll get a warning notification.

### Auto-reload

With `auto_reload = true` (default), Neovim's `autoread` is enabled and `checktime` is triggered on common events (`BufEnter`, `FocusGained`, `TermLeave`, etc.). This means files edited by Claude are automatically refreshed in your buffers without any manual intervention.

## Lua API

You can also send text programmatically:

```lua
require("claudeplz").send("explain this codebase")
```

## Health check

Run `:checkhealth claudeplz` to verify your setup — it checks the Neovim version, that the `claude` binary is reachable, that `git` is available and the current directory is inside a git repo (required for `send_diff` / `send_file_diff`), and that the plugin is configured correctly.

## Tips

### Resizing the Claude split

Claude runs in a terminal buffer, so normal-mode window resize keys won't work while you're in insert/terminal mode. Add these mappings to escape to normal mode, resize, and return:

```lua
-- macOS uses 'M' as the option key modifier; Linux uses 'A'
local optKey = vim.loop.os_uname().sysname == "Darwin" and "M" or "A"

-- Normal mode
vim.keymap.set("n", "<" .. optKey .. "-,>", "<C-W>5<", { desc = "Shrink split horizontally" })
vim.keymap.set("n", "<" .. optKey .. "-.>", "<C-W>5>", { desc = "Grow split horizontally" })
vim.keymap.set("n", "<" .. optKey .. "-j>", "<C-W>+",  { desc = "Grow split vertically" })
vim.keymap.set("n", "<" .. optKey .. "-k>", "<C-W>-",  { desc = "Shrink split vertically" })

-- Terminal mode — escape to normal, resize, return to terminal
vim.keymap.set("t", "<" .. optKey .. "-,>", [[<C-\><C-n><C-W>5<i]], { desc = "Shrink split horizontally" })
vim.keymap.set("t", "<" .. optKey .. "-.>", [[<C-\><C-n><C-W>5>i]], { desc = "Grow split horizontally" })
vim.keymap.set("t", "<" .. optKey .. "-j>", [[<C-\><C-n><C-W>+i]],  { desc = "Grow split vertically" })
vim.keymap.set("t", "<" .. optKey .. "-k>", [[<C-\><C-n><C-W>-i]],  { desc = "Shrink split vertically" })
```

### Split navigation with tmux-navigator

If you use [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator), re-apply its keymaps on `TermOpen` so they work inside the Claude terminal buffer:

```lua
vim.g.tmux_navigator_no_mappings = 1

local function set_tmux_keymaps()
  for _, mode in ipairs({ "n", "i", "v", "t" }) do
    vim.keymap.set(mode, "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  { desc = "Window left" })
    vim.keymap.set(mode, "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Window right" })
    vim.keymap.set(mode, "<C-j>", "<cmd>TmuxNavigateDown<CR>",  { desc = "Window down" })
    vim.keymap.set(mode, "<C-k>", "<cmd>TmuxNavigateUp<CR>",    { desc = "Window up" })
  end
end

set_tmux_keymaps()

vim.api.nvim_create_autocmd("TermOpen", { callback = set_tmux_keymaps })
```

## License

MIT

# aikido-tabs.nvim

A Neovim buffer tabline where tabs yield gracefully under pressure.

Like water redirecting force rather than resisting it, tabs shrink proportionally as space runs out — the widest giving way first, paths truncating with ellipses, elements disappearing only when they can no longer meaningfully contribute. Tabs naturally converge toward equal widths rather than clipping abruptly.

## How it works

Each tab is a tree of elements inspired by flexbox. Directory paths declare a flex alignment and a minimum visible length. When the tabline exceeds the terminal width, the plugin repeatedly shaves a character from the widest tab until everything fits. Once a path shrinks below its minimum it vanishes entirely — no unreadable stubs.

When many buffers are open the tabline becomes a sliding viewport centred on the active buffer, with overflow indicators at the edges.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "kizza/aikido-tabs.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional
  opts = {},
}
```

## Configuration

```lua
require("aikido-tabs").setup({
  icons = true, -- set false to disable file type icons
})
```

## Dependencies

- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (optional) — file type icons

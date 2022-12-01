# statuscol.nvim

Status column plugin that provides click handlers for the ['statuscolumn'](https://neovim.io/doc/user/options.html#'statuscolumn').
Requires Neovim >= 0.9

## Install

<!-- panvimdoc-ignore-start -->

Install with [packer](https://github.com/wbthomason/packer.nvim):

```lua
use({
  "luukvbaal/statuscol.nvim",
  config = function() require("statuscol").setup() end
})
```

<!-- panvimdoc-ignore-end -->

## Usage

This plugin provides four global VimL functions. `ScFa`, `ScSa` and `ScLa` are to be used as `%@` click-handlers for the fold, sign and line number segments in your `'statuscolumn'` string respectively.
`ScLn` can be used as the line number itself inside a `%{}` eval segment, configurable through the [`setup()`](#Configuration) function.

    vim.o.statuscolumn = "%@ScFa@%C%T%@ScLa@%s%T@ScNa@%=%{ScLn()}%T"

## Configuration

### Default actions

Currently the following builtin actions are supported:

**Still figuring out what signs could use, and what would make sense as default click actions. Suggestions welcome.**

|Sign|Button|Modifier|Action|
|----|------|--------|------|
|Lnum|Left||Toggle [DAP](https://github.com/mfussenegger/nvim-dap) breakpoint|
|Lnum|Left|<kbd>Ctrl</kbd>|Toggle DAP conditional breakpoint|
|Lnum|Middle||Yank line|
|Lnum|Right||Paste line|
|Lnum|Right x2||Delete line|
|FoldPlus|Left||Open fold|
|FoldPlus|Left|<kbd>Ctrl</kbd>|Open fold recursively|
|FoldMinus|Left||Close fold|
|FoldMinus|Left|<kbd>Ctrl</kbd>|Close fold recursively|
|FoldPlus/Minus|Right||Delete fold|
|FoldPlus/Minus|Right|<kbd>Ctrl</kbd>|Delete fold recursively|
|Fold*|Middle||Create fold in range(click twice)|
|Diagnostic*|Left||Open diagnostic [float](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float())|
|Diagnostic*|Middle||Select available [code action](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.code_action())|
|[GitSigns](https://github.com/lewis6991/gitsigns.nvim)*|Left||Preview hunk|
|GitSigns*|Middle||Reset hunk|
|GitSigns*|Right||Stage hunk|

### Custom actions

The `setup()` function accepts a table of functions. Each entry is the name of a sign, or `Lnum` and `FoldPlus/Minus/Empty` for the number and fold columns:

```lua
local builtin = require("statuscol.builtin")
local cfg = {
  separator = false,     -- separator between line number and buffer text ("│" or extra " " padding)
  thousands = false      -- or line number thousands separator string ("." / ",")
  statuscolumn = false,  -- whether to set the 'statuscolumn', providing the builtin click actions
  -- Click actions
  Lnum                   = builtin.lnum_click,
  FoldPlus               = builtin.foldplus_click,
  FoldMinus              = builtin.foldminus_click,
  FoldEmpty              = builtin.foldempty_click,
  DapBreakpointRejected  = builtin.toggle_breakpoint,
  DapBreakpoint          = builtin.toggle_breakpoint,
  DapBreakpointCondition = builtin.toggle_breakpoint,
  DiagnosticSignError    = builtin.diagnostic_click,
  DiagnosticSignHint     = builtin.diagnostic_click,
  DiagnosticSignInfo     = builtin.diagnostic_click,
  DiagnosticSignWarn     = builtin.diagnostic_click,
  GitSignsTopdelete      = builtin.gitsigns_click,
  GitSignsUntracked      = builtin.gitsigns_click,
  GitSignsAdd            = builtin.gitsigns_click,
  GitSignsChangedelete   = builtin.gitsigns_click,
  GitSignsDelete         = builtin.gitsigns_click,
}
```

To modify the default actions, pass a table of functions you want to overwrite to the `setup()` function:

```lua
local cfg = {
  ---@param args (table): {
  ---   minwid = minwid,            -- 1st argument to 'statuscolumn' %@ callback
  ---   clicks = clicks,            -- 2nd argument to 'statuscolumn' %@ callback
  ---   button = button,            -- 3rd argument to 'statuscolumn' %@ callback
  ---   mods = mods,                -- 4th argument to 'statuscolumn' %@ callback
  ---   mousepos = f.getmousepos()  -- getmousepos() table, containing clicked line number/window id etc.
  --- }
  Lnum = function(args)
    if args.button == "l" and args.mods:find("c") then
      print("I Ctrl-left clicked on line "..args.mousepos.line)
    end
  end,
}

require("statuscol").setup(cfg)
```

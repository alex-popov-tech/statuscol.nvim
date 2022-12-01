local a = vim.api
local f = vim.fn
local c = vim.cmd
local o = vim.o
local v = vim.v
local S = vim.schedule
local M = {}
local signs = {}
local builtin = require("statuscol.builtin")

local cfg = {
  separator = " ",
  thousands = false,
  statuscolumn = false,
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

--- Store defined signs without whitespace
local function update_sign_defined()
	for _, sign in ipairs(f.sign_getdefined()) do
		signs[sign.name] = sign.text:gsub("%s","")
	end
end

--- Store click args and fn.getmousepos() in table.
--- Set current window and mouse position to clicked line.
local function get_click_args(minwid, clicks, button, mods)
	local args = {
		minwid = minwid,
		clicks = clicks,
		button = button,
		mods = mods,
		mousepos = f.getmousepos()
	}
	a.nvim_set_current_win(args.mousepos.winid)
	a.nvim_win_set_cursor(0, {args.mousepos.line, 0})
	return args
end

--- Run fold column click callback
function M.get_fold_action(minwid, clicks, button, mods)
	local args = get_click_args(minwid, clicks, button, mods)
	local type = f.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
	type = type == " " and "FoldEmpty" or type == "+" and "FoldPlus" or "FoldMinus"

	if (cfg[type]) then
		S(function() cfg[type](args) end)
	end
end

--- Run sign column click callback
function M.get_sign_action(minwid, clicks, button, mods)
	local args = get_click_args(minwid, clicks, button, mods)
	local sign = f.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
	if sign == ' ' then
		sign = f.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
	end

	if not signs[sign] then update_sign_defined() end
	for name, text in pairs(signs) do
		if text == sign and cfg[name] then
			S(function() cfg[name](args) end)
			break
		end
	end
end

--- Run line number click callback
function M.get_lnum_action(minwid, clicks, button, mods)
	local args = get_click_args(minwid, clicks, button, mods)
	if (cfg.Lnum) then
		S(function() cfg.Lnum(args) end)
	end
end

function M.get_lnum_string()
  if v.wrap or (not o.relativenumber and not o.number) then return "" end
  local lnum = v.lnum

  if o.relativenumber then
    lnum = v.relnum > 0 and v.relnum or (o.number and lnum or 0)
  end

  if cfg.thousands and lnum > 999 then
    lnum = string.reverse(lnum):gsub("%d%d%d", "%1"..cfg.thousands):reverse():gsub("^%"..cfg.thousands, "")
  end

  return lnum
end

function M.setup(setup_cfg)
	if setup_cfg then cfg = vim.tbl_deep_extend("force", cfg, setup_cfg) end

	c([[
	function! ScFa(a, b, c, d)
	  call v:lua.require("statuscol").get_fold_action(a:a, a:b, a:c, a:d)
	endfunction
	function! ScSa(a, b, c, d)
	  call v:lua.require("statuscol").get_sign_action(a:a, a:b, a:c, a:d)
	endfunction
	function! ScLa(a, b, c, d)
	  call v:lua.require("statuscol").get_lnum_action(a:a, a:b, a:c, a:d)
	endfunction
  function! ScLn()
    return v:lua.require("statuscol").get_lnum_string()
  endfunction
	]])

  if cfg.statuscolumn then
    o.statuscolumn = "%@ScFa@%C%T%@ScSa@%s%T%@ScLa@%=%{ScLn()}%T"..cfg.separator
  end
end

return M

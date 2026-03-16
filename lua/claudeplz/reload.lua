local M = {}

M.setup = function(auto_reload)
	if not auto_reload then
		return
	end

	vim.opt.autoread = true

	vim.api.nvim_create_augroup("ClaudeplzAutoReload", { clear = true })
	vim.api.nvim_create_autocmd({
		"CursorHold",
		"CursorHoldI",
		"FocusGained",
		"BufEnter",
		"TermLeave",
		"TermEnter",
		"BufWinEnter",
	}, {
		group = "ClaudeplzAutoReload",
		pattern = "*",
		callback = function()
			if vim.opt.buftype:get() == "" then
				vim.cmd("checktime")
			end
		end,
	})
end

return M

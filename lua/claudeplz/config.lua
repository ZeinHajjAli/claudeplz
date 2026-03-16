local M = {}

M.defaults = {
	auto_reload = true,
	mappings = {
		split = '<leader>c"',
		vsplit = "<leader>c%",
		send_file = "<leader>cf",
		send_sel = "<leader>cs",
		send_diag = "<leader>cd",
	},
}

M.values = {}

M.setup = function(opts)
	M.values = vim.tbl_deep_extend("force", M.defaults, opts or {})
	return M.values
end

return M

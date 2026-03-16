local M = {}

M.setup = function(opts)
	local config = require("claudeplz.config").setup(opts)
	require("claudeplz.ui").apply_mappings(config.mappings)
	require("claudeplz.reload").setup(config.auto_reload)
end

M.send = function(text)
	require("claudeplz.session").send(text)
end

return M

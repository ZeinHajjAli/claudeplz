local M = {}

local map = function(mode, keys, func, desc)
	vim.keymap.set(mode, keys, func, { desc = "Claudeplz: " .. desc })
end

M.apply_mappings = function(mappings)
	local session = require("claudeplz.session")
	local context = require("claudeplz.context")

	local function send(getter, warn)
		local text = getter()
		if not text then
			vim.notify(warn, vim.log.levels.WARN)
			return
		end
		session.send(text)
	end
	if mappings.split ~= false then
		map("n", mappings.split, function()
			session.start("new")
		end, "horizontal split")
	end
	if mappings.vsplit ~= false then
		map("n", mappings.vsplit, function()
			session.start("vnew")
		end, "vertical split")
	end
	if mappings.send_file ~= false then
		map("n", mappings.send_file, function()
			send(context.from_file, "Could not read file.")
		end, "send current file")
	end
	if mappings.send_sel ~= false then
		map("v", mappings.send_sel, function()
			send(context.from_selection, "Nothing selected.")
		end, "send selection")
	end
	if mappings.send_diag ~= false then
		map("n", mappings.send_diag, function()
			send(context.from_diagnostics, "No diagnostics in current buffer.")
		end, "send diagnostics")
	end
	if mappings.send_diff ~= false then
		map("n", mappings.send_diff, function()
			send(context.from_diff, "No diff available.")
		end, "send git diff")
	end
	if mappings.send_file_diff ~= false then
		map("n", mappings.send_file_diff, function()
			send(context.from_file_diff, "No diff for current file.")
		end, "send current file git diff")
	end
end

return M

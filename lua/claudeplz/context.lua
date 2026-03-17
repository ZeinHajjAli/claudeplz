local M = {}

M.get_visual_selection = function()
	local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "x", false)

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local s_row, s_col = start_pos[2] - 1, start_pos[3] - 1
	local e_row, e_col = end_pos[2] - 1, end_pos[3]
	local v_mode = vim.fn.visualmode()

	local lines
	if v_mode == "\22" then
		lines = {}
		for row = s_row, e_row do
			local row_lines = vim.api.nvim_buf_get_text(0, row, s_col, row, e_col, {})
			if row_lines[1] then
				table.insert(lines, row_lines[1])
			end
		end
	else
		lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
	end

	if not lines or #lines == 0 then
		return nil
	end

	return table.concat(lines, "\n")
end

local wrap_in_fence = function(content, filetype, label)
	return string.format("\n%s\n```%s\n%s\n```\n", label, filetype, content)
end

M.from_selection = function()
	local sel = M.get_visual_selection()
	if not sel then
		return nil
	end
	return wrap_in_fence(sel, vim.bo.filetype, "from " .. vim.fn.expand("%:t"))
end

M.from_file = function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return wrap_in_fence(table.concat(lines, "\n"), vim.bo.filetype, vim.fn.expand("%:t"))
end

M.from_diagnostics = function()
	local diags = vim.diagnostic.get(0)
	if #diags == 0 then
		return nil
	end

	local parts = { "Diagnostics for " .. vim.fn.expand("%:t") .. ":" }
	for _, d in ipairs(diags) do
		local sev = vim.diagnostic.severity[d.severity] or "UNKNOWN"
		table.insert(parts, string.format("[%s] line %d: %s", sev, d.lnum + 1, d.message))
	end
	return "\n" .. table.concat(parts, "\n") .. "\n"
end

M.from_diff = function(opts)
	opts = opts or {}

	local cmd
	if opts.file then
		cmd = "git diff HEAD " .. vim.fn.shellescape(opts.file)
	elseif opts.staged then
		cmd = "git diff --staged"
	else
		cmd = "git diff HEAD"
	end

	local result = vim.fn.system(cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("git diff failed: " .. result, vim.log.levels.WARN)
		return nil
	end

	if result == "" then
		vim.notify("No changes to diff", vim.log.levels.INFO)
		return nil
	end

	return string.format("\n```diff\n%s\n```\n", result)
end

M.from_file_diff = function()
	return M.from_diff({ file = vim.fn.expand("%") })
end

return M

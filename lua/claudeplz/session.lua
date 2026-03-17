local M = {}

local sessions = {}

local current_tab = function()
	return vim.api.nvim_get_current_tabpage()
end

M.get = function()
	return sessions[current_tab()]
end

M.get_all = function()
	return sessions
end

M.clear = function(tab)
	sessions[tab] = nil
end

M.start = function(split_cmd)
	split_cmd = split_cmd or "vnew"

	local existing = M.get()
	if existing and vim.api.nvim_win_is_valid(existing.win) then
		vim.api.nvim_set_current_win(existing.win)
		vim.cmd("startinsert")
		return
	end

	vim.cmd(split_cmd)

	local tab = current_tab()
	local term_win = vim.api.nvim_get_current_win()
	local term_buf = vim.api.nvim_get_current_buf()

	local config = require("claudeplz.config")
	local args = config.values.cli_args or {}
	local cmd = vim.list_extend({ "claude" }, args)
	local job_id = vim.fn.jobstart(cmd, {
		term = true,
		cwd = vim.fn.getcwd(),
		on_exit = function(_, exit_code, _)
			vim.schedule(function()
				M.clear(tab)
				vim.notify("closing claude")
				if vim.api.nvim_buf_is_valid(term_buf) then
					vim.api.nvim_buf_delete(term_buf, { force = true })
				end
				if vim.api.nvim_win_is_valid(term_win) then
					vim.api.nvim_win_close(term_win, true)
				end
				vim.notify("closed claude")
				if exit_code ~= 0 then
					vim.notify("Claude exited with code: " .. exit_code, vim.log.levels.WARN)
				end
			end)
		end,
	})

	sessions[tab] = { job_id = job_id, buf = term_buf, win = term_win }
	vim.cmd("startinsert")
end

M.send = function(text)
	local session = M.get()
	if not session then
		vim.notify("No Claude session on this tab. Open one first.", vim.log.levels.WARN)
		return
	end
	if vim.api.nvim_win_is_valid(session.win) then
		vim.api.nvim_set_current_win(session.win)
	end
	vim.fn.chansend(session.job_id, text)
end

return M

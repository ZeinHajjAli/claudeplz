local M = {}

M.check = function()
	vim.health.start("claudeplz")

	if vim.fn.has("nvim-0.8") == 1 then
		vim.health.ok("nvim >= 0.8")
	else
		vim.health.error("nvim >= 0.8 required", "Please upgrade neovim")
	end

	if vim.fn.executable("claude") == 1 then
		local result = vim.fn.system("claude --version")
		if vim.v.shell_error == 0 then
			vim.health.ok("claude found: " .. result:gsub("%s+$", ""))
		else
			vim.health.ok("claude found (version unknown)")
		end
	else
		vim.health.error(
			"`claude` binary not found in PATH",
			"Install Claude Code: https://code.claude.com/docs/en/overview"
		)
	end

	if vim.fn.executable("git") == 1 then
		local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("%s+$", "")
		if is_git_repo == "true" then
			vim.health.ok("git found, inside a git repo")
		else
			vim.health.ok("git found")
			vim.health.warn("not inside a git repo", "send_diff and send_file_diff will not work")
		end
	else
		vim.health.warn("git not found", "send_diff and send_file_diff features will not work")
	end

	local ok, session = pcall(require, "claudeplz.session")
	if ok then
		vim.health.ok("claudeplz.session loaded")
		local all = session.get_all()
		local count = vim.tbl_count(all)
		if count > 0 then
			for tab, s in pairs(all) do
				vim.health.info("active session on tab " .. tostring(tab) .. " (job_id: " .. tostring(s.job_id) .. ")")
			end
		else
			vim.health.info("no active sessions")
		end
	else
		vim.health.error("failed to load claudeplz.session: " .. tostring(session))
	end

	local cfg_ok, config = pcall(require, "claudeplz.config")
	if cfg_ok and config.values and config.values.mappings then
		vim.health.ok("config loaded")
		vim.health.info("auto_reload: " .. tostring(config.values.auto_reload))
		for name, key in pairs(config.values.mappings) do
			if key ~= false then
				vim.health.info(string.format("mapping %-12s %s", name .. ":", key))
			else
				vim.health.info(string.format("mapping %-12s disabled", name .. ":", key))
			end
		end
	else
		vim.health.error("config not loaded or missing values - was setup() called?")
	end
end

return M

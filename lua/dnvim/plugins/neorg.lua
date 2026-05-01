return {
	"nvim-neorg/neorg",
	lazy = false,
	version = "*",
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.dirman"] = {
					config = {
						use_popup = false,
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function(args)
				pcall(vim.treesitter.stop, args.buf)
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "NeorgStarted",
			once = true,
			callback = function()
				local modules = require("neorg.core.modules")
				local dirman = modules.get_module("core.dirman")
				if not dirman then
					return
				end

				local function edit_in_normal_window(filepath)
					local target_win
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						local win_cfg = vim.api.nvim_win_get_config(win)
						if win_cfg.relative == "" then
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].buftype == "" then
								target_win = win
								break
							end
						end
					end

					if target_win then
						vim.api.nvim_set_current_win(target_win)
					end

					vim.cmd("edit " .. vim.fn.fnameescape(filepath))
				end

				local original_create_file = dirman.create_file
				dirman.create_file = function(path, workspace, opts)
					opts = opts or {}
					local should_open = not opts.no_open
					local actual_opts = vim.tbl_extend("force", opts, { no_open = true })

					original_create_file(path, workspace, actual_opts)

					if not should_open then
						return
					end

					local workspace_root = workspace and dirman.get_workspace(workspace) or dirman.get_current_workspace()[2]
					if not workspace_root then
						return
					end

					local filepath = ((workspace_root / path):add_suffix(".norg")):tostring()
					edit_in_normal_window(filepath)
				end

				local original_open_file = dirman.open_file
				dirman.open_file = function(workspace_name, path)
					local workspace = dirman.get_workspace(workspace_name)
					if not workspace then
						return original_open_file(workspace_name, path)
					end
					edit_in_normal_window((workspace / path):tostring())
				end
			end,
		})
	end,
}

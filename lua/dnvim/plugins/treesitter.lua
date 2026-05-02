return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup()

			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.norg_meta = {
				install_info = {
					url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
					files = { "src/parser.c" },
					branch = "main",
				},
				filetype = "norg_meta",
			}

			-- Guard buggy node captures in injection directives (seen as node:range() nil)
			local query = require("vim.treesitter.query")
			local opts = vim.fn.has("nvim-0.10") == 1 and { force = true, all = false } or true
			query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
				local node = match[pred[2]]
				if not node or type(node) ~= "userdata" then
					return
				end

				local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
				if not ok or type(text) ~= "string" or text == "" then
					return
				end

				metadata["injection.language"] = vim.filetype.match({ filename = "a." .. text:lower() }) or text:lower()
			end, opts)

			local group = vim.api.nvim_create_augroup("dnvim_treesitter_start", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = {
					"bash",
					"c",
					"diff",
					"go",
					"help",
					"html",
					"lua",
					"markdown",
					"ocaml",
					"vim",
				},
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},
}

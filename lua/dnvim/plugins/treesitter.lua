return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup()

			local function add_neorg_parsers()
				local parsers = require("nvim-treesitter.parsers")
				parsers.norg = {
					install_info = {
						url = "https://github.com/nvim-neorg/tree-sitter-norg",
						branch = "main",
					},
				}
				parsers.norg_meta = {
					install_info = {
						url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
						branch = "main",
					},
				}
			end

			add_neorg_parsers()
			vim.api.nvim_create_autocmd("User", {
				pattern = "TSUpdate",
				callback = add_neorg_parsers,
			})
			vim.treesitter.language.register("norg", "norg")
			vim.treesitter.language.register("norg_meta", "norg_meta")

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

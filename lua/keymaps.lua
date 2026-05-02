vim.g.mapleader = " "

vim.keymap.set("n", "<leader>-", vim.cmd.Ex)
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open Diagnostic Float" })
-- REMAPS
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<F5>", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>g", "<cmd>Git<CR>")
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")

local notes_root = vim.fn.expand("~/notes")

local function create_from_template(template_relpath, target_rel_dir, prompt, default_name)
	local name = vim.fn.input(prompt, default_name or "")
	if name == nil or name == "" then
		return
	end

	if not name:match("%.norg$") then
		name = name .. ".norg"
	end

	local template_path = notes_root .. "/99-templates/" .. template_relpath
	local target_dir = notes_root .. "/" .. target_rel_dir
	local target_path = target_dir .. "/" .. name

	vim.fn.mkdir(target_dir, "p")

	if vim.fn.filereadable(target_path) == 1 then
		vim.notify("File exists: " .. target_path, vim.log.levels.WARN)
		vim.cmd("edit " .. vim.fn.fnameescape(target_path))
		return
	end

	if vim.fn.filereadable(template_path) == 0 then
		vim.notify("Template missing: " .. template_path, vim.log.levels.ERROR)
		return
	end

	local lines = vim.fn.readfile(template_path)
	vim.fn.writefile(lines, target_path)
	vim.cmd("edit " .. vim.fn.fnameescape(target_path))
end

vim.keymap.set("n", "<leader>ntd", function()
	create_from_template("daily.norg", "01-today", "Daily filename: ", os.date("%Y-%m-%d"))
end, { desc = "Neorg new daily note" })

vim.keymap.set("n", "<leader>ntp", function()
	create_from_template("project.norg", "02-projects/active", "Project filename: ", "proj-")
end, { desc = "Neorg new project note" })

vim.keymap.set("n", "<leader>ntk", function()
	create_from_template("knowledge.norg", "03-knowledge", "Knowledge filename: ", "")
end, { desc = "Neorg new knowledge note" })

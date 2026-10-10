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

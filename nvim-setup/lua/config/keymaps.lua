local mapkey = require("util.keymapper").mapkey

-- Directory Navigatio}n
mapkey("<leader>m", "NvimTreeFocus", "n")
mapkey("<C-b>", "NvimTreeToggle", "n")

-- Pane and Window Navigation
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true }) -- Navigate Left
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true }) -- Navigate Down
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true }) -- Navigate Down
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true }) -- Navigate Right

-- Window Management
mapkey("<leader>sv", "vsplit", "n") -- Split Vertically
mapkey("<leader>sh", "split", "n") -- Split Horizontally
mapkey("<leader>sm", "MaximizerToggle", "n") -- Toggle Minimise
vim.api.nvim_set_keymap("n", "<C-q>", "<C-w>q", { noremap = true, silent = true }) -- Navigate close


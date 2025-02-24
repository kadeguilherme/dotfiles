-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = LazyVim.safe_keymap_set

-- Terminal flutuante no diretório atual
map("n", "<leader>ft", function()
  require("snacks.terminal").toggle(vim.o.shell, {
    cwd = vim.fn.expand("%:p:h"),
  })
end, { desc = "Toggle Floating Terminal" })

-- Terminal flutuante no diretório raiz do projeto
vim.keymap.set("n", "<leader>fT", function()
  local cwd = vim.fn.expand("%:p:h")
  require("snacks.terminal").open(vim.o.shell, { cwd = vim.fn.expand("%:p:h") })
end, {

  desc = "New Floating Terminal",
})

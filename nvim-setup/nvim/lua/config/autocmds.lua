-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.cmd([[
  augroup UpdateTerminalCwd
    autocmd!
    autocmd BufEnter * if &filetype != 'toggleterm' | let g:terminal_cwd = expand('%:p:h') | endif
  augroup END
]])

-- Autocomando para atualizar o diretório do terminal sempre que mudar de buffer
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    -- Verifica se o tipo de arquivo não é 'toggleterm' antes de mudar o diretório
    if vim.bo.filetype ~= "toggleterm" then
      -- Atualiza o diretório de trabalho para o diretório do arquivo no buffer
      local cwd = vim.fn.expand("%:p:h")
      vim.g.terminal_cwd = cwd
    end
  end,
})

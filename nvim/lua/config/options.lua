vim.g.mapleader = " "

-- numeros / cursor
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

-- indentacaoo (yaml usa 2; ver after/ftplugin/yaml.lua)
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- busca
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split" -- preview ao vivo do :s/.../.../

-- splits abrem a direita / abaixo
vim.opt.splitright = true
vim.opt.splitbelow = true

-- diversos
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.wrap = true
vim.opt.confirm = true -- pergunta em vez de falhar ao sair com buffer nao salvo
vim.opt.updatetime = 250 -- CursorHold mais responsivo (gitsigns blame, hover, ...)
vim.opt.timeoutlen = 400 -- which-key aparece mais rapido

-- Fecha (deleta) o buffer atual sem sair do Neovim
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Salvar / sair.
-- Vim ja tem embutido: ZZ salva e sai, ZQ sai descartando.
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR>", { desc = "Salvar arquivo" })
vim.keymap.set("n", "<leader>qq", "<Cmd>qall!<CR>", { desc = "Sair descartando alterações" })
vim.keymap.set("n", "<leader>qw", "<Cmd>write<CR><Cmd>quit<CR>", { desc = "Salvar e fechar a janela" })
vim.keymap.set("n", "<leader>qx", "<Cmd>wqall!<CR>", { desc = "Salvar tudo e sair" })

-- limpa o realce da ultima busca
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Limpar realce da busca" })

-- mantem a selecao apos indentar em modo visual
vim.keymap.set("v", "<", "<gv", { desc = "Desindentar mantendo seleção" })
vim.keymap.set("v", ">", ">gv", { desc = "Indentar mantendo seleção" })

-- tmux: abre pane no diretorio do buffer atual
local function tmux_split(orientation)
  return function()
    vim.fn.system({ "tmux", "split-window", orientation, "-c", vim.fn.expand("%:p:h") })
  end
end

vim.keymap.set("n", "<leader>th", tmux_split("-h"), { desc = "tmux: pane horizontal no dir do buffer" })
vim.keymap.set("n", "<leader>tv", tmux_split("-v"), { desc = "tmux: pane vertical no dir do buffer" })

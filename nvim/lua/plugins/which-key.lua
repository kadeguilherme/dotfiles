-- which-key.nvim
-- https://github.com/folke/which-key.nvim
-- Popup showing available keymaps and their descriptions as you type.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Nomes dos grupos de prefixo. Sem isso o popup mostra só "+prefix".
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code / LSP" },
      { "<leader>d", group = "debug" },
      { "<leader>dg", group = "debug: go" },
      { "<leader>f", group = "find (telescope)" },
      { "<leader>g", group = "git remoto (PR/commit)" },
      { "<leader>h", group = "hunk (git)" },
      { "<leader>l", group = "lazygit" },
      { "<leader>q", group = "sair / salvar" },
      { "<leader>s", group = "search & replace" },
      { "<leader>t", group = "tmux" },
      { "<leader>u", group = "toggles / UI" },
      { "<leader>w", group = "workspace / sessão" },
      { "[", group = "anterior" },
      { "]", group = "próximo" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Keymaps locais do buffer (which-key)",
    },
  },
}

-- auto-session
-- https://github.com/rmagatti/auto-session
-- Save and restore Neovim sessions per working directory.
return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>wr", "<cmd>AutoSession restore<cr>", desc = "Restore session for cwd" },
    { "<leader>ws", "<cmd>AutoSession save<cr>", desc = "Save session for cwd" },
  },
  opts = {
    suppressed_dirs = { "~/", "/" },
    -- salva a sessão automaticamente ao sair, mas a restauração é manual
    -- (via <leader>wr ou o botão do alpha); assim você controla quando restaurar
    auto_save = true,
    auto_restore = false,
    session_lens = {
      -- O padrão é `true`, o que registra a extensão do Telescope durante o setup
      -- do auto-session e força o carregamento de `telescope.nvim` e `plenary.nvim`
      -- no startup. Mantendo `false`, ambos continuam em lazy-load.
      load_on_setup = false,
    },
  },
}

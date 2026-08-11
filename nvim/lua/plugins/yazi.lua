-- yazi.nvim
-- https://github.com/mikavilpas/yazi.nvim
-- File manager in Neovim backed by yazi, with netrw disabled.
return {
  "mikavilpas/yazi.nvim",
  -- sem `event`: as `keys` abaixo ja carregam, e o `init` (netrw) roda sempre.
  -- com `open_for_directories = false` nao ha nada para interceptar no startup.
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>e",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      "<leader>E",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-s>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
    },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}

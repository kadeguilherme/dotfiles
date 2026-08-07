-- copilot.lua
-- https://github.com/zbirenbaum/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  cmd = "Copilot",
  keys = {
    {
      "<leader>uc",
      function()
        require("util.toggles").copilot()
      end,
      desc = "Copilot: sugestão automática (buffer)",
    },
  },
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = false,
      debounce = 75,
      keymap = {
        accept = "<M-l>", -- aceita a sugestão inteira
        accept_word = "<M-w>", -- aceita só a próxima palavra
        accept_line = "<M-j>", -- aceita só a linha atual
        next = "<M-n>", -- próxima alternativa
        prev = "<M-p>", -- alternativa anterior
        dismiss = "<M-d>", -- descarta até a próxima digitação
      },
    },

    panel = {
      enabled = true,
      auto_refresh = true,
      keymap = {
        jump_prev = "<M-,>",
        jump_next = "<M-.>",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = { position = "bottom", ratio = 0.4 },
    },

    filetypes = {
      yaml = true,
      markdown = true,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false, -- buffers sem nome
    },
  },
}

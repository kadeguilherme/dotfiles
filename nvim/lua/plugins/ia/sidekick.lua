-- sidekick.nvim
-- https://github.com/folke/sidekick.nvim
-- Próxima edição sugerida (Copilot NES) + ponte para CLIs de IA (opencode, claude).
-- Guia de uso: lua/plugins/ia/README.md
return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    cli = {
      -- Com tmux instalado, a sessão do agente sobrevive ao fechar o nvim.
      -- Sem tmux (ex.: outra máquina), roda num terminal comum do nvim.
      mux = { backend = "tmux", enabled = vim.fn.executable("tmux") == 1 },
    },
  },
  keys = {
    -- Próxima edição: 1º <Tab> pula até ela, 2º aplica. Sem sugestão, <Tab> normal.
    {
      "<Tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "IA: ir para / aplicar próxima edição",
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "IA: abrir/fechar CLI",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").select()
      end,
      desc = "IA: escolher CLI",
    },
    {
      "<leader>ao",
      function()
        require("sidekick.cli").toggle({ name = "opencode", focus = true })
      end,
      desc = "IA: opencode",
    },
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end,
      desc = "IA: Claude Code",
    },
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "n", "x" },
      desc = "IA: enviar isto (cursor/seleção)",
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "IA: enviar arquivo",
    },
    {
      "<leader>av",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = "x",
      desc = "IA: enviar seleção",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "IA: prompts prontos",
    },
    {
      "<leader>ad",
      function()
        require("sidekick.cli").close()
      end,
      desc = "IA: desanexar sessão",
    },
  },
}

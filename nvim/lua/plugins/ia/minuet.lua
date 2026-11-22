-- minuet-ai.nvim
-- https://github.com/milanglacier/minuet-ai.nvim
-- Ghost text de IA com o provedor que você escolher. Substituto do copilot.lua.
--
-- DESLIGADO enquanto o plano do Copilot existir. Quando ele acabar:
--   1. Crie uma chave do Codestral em https://console.mistral.ai (menu Codestral)
--   2. Exporte no shell (~/.bashrc):  export CODESTRAL_API_KEY="sua-chave"
--   3. Troque `enabled = false` por `enabled = true` aqui embaixo
--   4. Em lua/plugins/ia/copilot.lua, adicione `enabled = false` no spec
--   5. Reabra o nvim e rode :Lazy sync
--
-- Atenção: o código do buffer é enviado para a Mistral. Confira se a política
-- da empresa permite antes de usar em repositórios do trabalho.
return {
  "milanglacier/minuet-ai.nvim",
  enabled = false,
  event = "InsertEnter",
  cmd = "Minuet",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    -- mesmo atalho do toggle do Copilot (só um dos dois plugins fica ligado)
    { "<leader>uc", "<cmd>Minuet virtualtext toggle<cr>", desc = "Minuet: sugestão automática (buffer)" },
  },
  config = function()
    require("minuet").setup({
      provider = "codestral",

      provider_options = {
        codestral = {
          model = "codestral-latest",
          end_point = "https://codestral.mistral.ai/v1/fim/completions",
          api_key = "CODESTRAL_API_KEY", -- NOME da variável de ambiente, não a chave
          stream = true,
          optional = {
            max_tokens = 256,
            stop = { "\n\n" }, -- para no fim do bloco, evitando sugestões gigantes
          },
        },
      },

      -- Ghost text, com os mesmos atalhos do copilot.lua onde existe equivalente.
      -- O minuet não tem "aceitar só a próxima palavra" (<M-w> do Copilot).
      virtualtext = {
        auto_trigger_ft = { "*" },
        auto_trigger_ignore_ft = { "help", "gitcommit", "gitrebase", "hgcommit", "svn", "cvs" },
        keymap = {
          accept = "<M-l>", -- aceita a sugestão inteira
          accept_line = "<M-j>", -- aceita só a linha atual
          next = "<M-n>", -- próxima alternativa
          prev = "<M-p>", -- alternativa anterior
          dismiss = "<M-d>", -- descarta a sugestão
        },
      },

      n_completions = 1, -- uma sugestão por vez gasta menos cota
      request_timeout = 3, -- segundos
    })
  end,
}

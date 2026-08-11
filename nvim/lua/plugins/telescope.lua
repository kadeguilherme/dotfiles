return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope", -- garante que :Telescope funcione (ex: botões do alpha)
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      -- sorter em C: diferença bem visível no live_grep de repo grande
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      -- se o `make` falhar (sem gcc/make), o telescope segue com o sorter em Lua
      cond = function()
        return vim.fn.executable("make") == 1
      end,
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  },
  opts = function()
    -- "pasta/arquivo", crescendo só o necessário para não ficar ambíguo entre os
    -- buffers abertos — mesma regra do <leader>bb, para os dois combinarem.
    -- Encurtar o display NÃO atrapalha a busca: o telescope filtra pelo campo
    -- `ordinal`, que segue com o caminho completo, então dá para digitar
    -- "shard-abcd" mesmo o rótulo mostrando "pads/terragrunt.hcl".
    local function pasta_e_arquivo(_, path)
      local paths = require("util.paths")
      return paths.unique_suffix(path, paths.listed_buffer_names(), 2)
    end

    return {
      defaults = {
        file_ignore_patterns = { "%.git/", "node_modules/" }, -- ignora ruído nas buscas

        -- O default do telescope ancora o caminho à ESQUERDA e corta a direita,
        -- que em monorepo profundo mostra só o prefixo que todos compartilham.
        -- "truncate" corta pela esquerda (direction = -1 no path_truncate) e é
        -- ciente da largura da janela, então aproveita o espaço mostrando o FIM.
        path_display = { "truncate" },

        layout_strategy = "horizontal",
        layout_config = {
          horizontal = { preview_width = 0.5 },
          width = 0.92,
          height = 0.85,
        },
      },
      pickers = {
        find_files = {
          hidden = true, -- acha também arquivos ocultos (.env, .gitignore, ...)
        },
        buffers = {
          path_display = pasta_e_arquivo,
          sort_mru = true, -- mais recentes primeiro, em vez de ordem de bufnr
          ignore_current_buffer = true, -- não lista onde você já está
          disable_coordinates = true, -- tira o ":1" que não diz nada aqui
        },
        oldfiles = {
          path_display = pasta_e_arquivo,
        },
      },
    }
  end,
}

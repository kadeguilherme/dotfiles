-- telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim
-- Fuzzy finder: files, grep, buffers and the LSP pickers used in coding/lsp.lua.
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope", -- garante que :Telescope funcione (ex: botões do alpha)
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      -- sorter em C: diferença bem visível no live_grep de repo grande
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      -- sem `make` a dependência nem entra no spec
      cond = function()
        return vim.fn.executable("make") == 1
      end,
      -- o `cond` acima só garante que o `make` EXISTE; se a compilação falhar
      -- (sem gcc, header faltando), `require "fzf_lib"` estoura aqui dentro.
      -- Com o pcall o telescope segue com o sorter em Lua, só mais lento.
      config = function()
        if not pcall(require("telescope").load_extension, "fzf") then
          vim.notify("fzf-native não compilado (:Lazy build); usando o sorter em Lua", vim.log.levels.WARN)
        end
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
    --
    -- A referência é uma função, resolvida no render: os buffers abertos mudam
    -- entre uma abertura do picker e a seguinte. O util.paths memoiza o índice,
    -- então repetir a mesma lista a cada tecla não recalcula nada.
    ---@param referencia fun(): string[]
    local function pasta_e_arquivo(referencia)
      return function(_, path)
        return require("util.paths").unique_suffix(path, referencia(), 2)
      end
    end

    return {
      defaults = {
        -- `%.git/` sem ancorar, para pegar submódulo e repo aninhado também.
        -- `.terraform/` guarda providers e módulos vendorizados: sem isto o
        -- live_grep em monorepo de shards vem inundado deles.
        file_ignore_patterns = { "%.git/", "node_modules/", "%.terraform/", "vendor/" },

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
          path_display = pasta_e_arquivo(function()
            return require("util.paths").listed_buffer_names()
          end),
          sort_mru = true, -- mais recentes primeiro, em vez de ordem de bufnr
          ignore_current_buffer = true, -- não lista onde você já está
          disable_coordinates = true, -- tira o ":1" que não diz nada aqui
        },
        oldfiles = {
          -- Desambigua contra os PRÓPRIOS recentes, não contra os buffers: um
          -- arquivo do oldfiles quase nunca está aberto, então comparar com os
          -- buffers daria o mesmo rótulo para `shard-a/main.tf` e `shard-b/main.tf`.
          path_display = pasta_e_arquivo(function()
            return vim.v.oldfiles
          end),
        },
      },
    }
  end,
}

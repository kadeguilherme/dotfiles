
-------------------------------------------------
-- name : nvim-treesitter
-- url  : https://github.com/nvim-treesitter/nvim-treesitter
-------------------------------------------------
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
      local ts_config = require("nvim-treesitter.configs")
      ts_config.setup({
        ensure_installed = {
          "bash", "c", "dockerfile", "gitignore", "go", "lua", "hcl", "helm",
          "vim", "vimdoc", "jq", "query", "json", "terraform", "html",
          "markdown", "markdown_inline"
        },
        highlight = { enable = true },
        indent = { enable = true },  -- Habilitar indentação via Treesitter
      })
    end
  },
  -- Plugin mini.indentscope
  {
    'echasnovski/mini.indentscope',
    config = function()
      require('mini.indentscope').setup({
        draw = {
          delay = 0,  -- Desenho imediato
          animation = require('mini.indentscope').gen_animation.none(),  -- Sem animações
        },
        symbol = "¦",  -- Símbolo de indentação
        options = {
          try_default = true,
        },
      })
    end
  }
}


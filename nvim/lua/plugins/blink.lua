-- blink.cmp
-- https://github.com/Saghen/blink.cmp
-- Fast completion for Neovim: supports LSP, snippets, path and buffer.
return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- Preset padrão:
    -- <C-Space> abre o menu
    -- <CR> confirma a sugestão selecionada (ou quebra a linha)
    -- <C-E> cancela
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
  },

    appearance = { nerd_font_variant = "mono" },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { border = "rounded" },
      ghost_text = { enabled = true },
    },

    signature = { enabled = true, window = { border = "rounded" } },

    sources = {
      default = { "lsp", "path", "snippets", "buffer", "lazydev" },
      providers = {
      -- Prioriza sugestões do LazyDev em arquivos Lua.
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}

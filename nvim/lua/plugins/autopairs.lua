-- nvim-autopairs
-- https://github.com/windwp/nvim-autopairs
-- Auto-close and auto-pair brackets, quotes and more while typing.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true, -- usa Tree-sitter para decisões mais inteligentes
  },
}

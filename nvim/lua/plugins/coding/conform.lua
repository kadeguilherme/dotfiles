-- conform.nvim
-- https://github.com/stevearc/conform.nvim
-- Lightweight formatter: runs formatters on save or on demand.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        -- <leader>cf formata mesmo com o autoformat off
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Formatar arquivo",
    },
    {
      "<leader>uf",
      function()
        require("util.toggles").autoformat()
      end,
      desc = "Autoformat ao salvar (buffer)",
    }
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      go = { "goimports", "gofumpt" }, -- roda em ordem: organiza imports e depois formata
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      hcl = { "terraform_fmt" },
      python = { "ruff_organize_imports", "ruff_format" },
      yaml = { "yamlfmt" },
    },
    formatters = {
      --[[
      yamlfmt = {
        -- preserva o `---` no topo, que o yamlfmt apaga por padrão
        prepend_args = { "-formatter", "include_document_start=true" },
      },
      ]]
    },
    format_on_save = function(bufnr)
      if require("util.toggles").autoformat_desligado(bufnr) then
        return
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
  },
}

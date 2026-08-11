-- mason.nvim
-- https://github.com/mason-org/mason.nvim
-- Manage LSP servers, linters and formatters as external packages.
return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  -- mason-tool-installer.nvim
  -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
  -- Auto-install and manage a fixed set of Mason packages.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua", -- Lua (formatter)
        "shfmt", -- Bash/sh (formatter)
        "gofumpt", -- Go (formatter)
        "goimports", -- Go (formatter)
        "delve", -- Go (debugger / nvim-dap)
        "debugpy", -- Python (debugger / nvim-dap)
        "tflint", -- Terraform (linter)
        "yamllint", -- YAML (linter)
        "yamlfmt", -- YAML/Kubernetes (formatter)
        "trivy", -- Kubernetes/IaC (linter de misconfig e segurança)
      },
      run_on_start = true,
    },
  },
}

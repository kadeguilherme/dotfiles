-------------------------------------------------
-- name : mason-lspconfig.nvim
-- url  : https://github.com/williamboman/mason-lspconfig.nvim
-------------------------------------------------
return {
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ansiblels",                       --ansible
          "lua_ls",                          -- Lua
          "bashls",                          -- bash
          "clangd",                          -- C
          "docker_compose_language_service", -- docker
          "helm_ls",                         -- helm
          "jqls",                            -- jq
          "jsonls",                          --json
          "pyright",                         -- python
          "terraformls",                     --terraform
        },
      })
    end,
  },
}

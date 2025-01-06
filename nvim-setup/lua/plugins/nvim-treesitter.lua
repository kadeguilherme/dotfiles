-------------------------------------------------
-- name : nvim-treesitter
-- url  : https://github.com/nvim-treesitter/nvim-treesitter
-------------------------------------------------
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
        local config =  require("nvim-treesitter.configs")
        config.setup({
          ensure_installed = { "bash", "c", "dockerfile", "gitignore", "go", "lua","hcl", "helm", "vim", "vimdoc", "jq", "query", "json", "terraform", "html", "markdown", "markdown_inline" },
          highlight = { enable = true },
          indent = { enable = true },
        })
    end
}

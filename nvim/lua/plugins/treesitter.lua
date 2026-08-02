-- nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter
-- Tree-sitter bindings for Neovim: parsing, highlighting and text objects.
return {
  "nvim-treesitter/nvim-treesitter",
  -- ATENÇÃO ao branch. O default do repo hoje é "main", que exige Neovim >= 0.12
  branch = "main",
  build = ":TSUpdate",

  config = function()
    require("nvim-treesitter").install({
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
      "bash",
      "json",
      "yaml",
      "toml",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "hcl",
      "terraform",
      "python",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ok, parser = pcall(vim.treesitter.get_parser, args.buf)

        if ok and parser then
          vim.treesitter.start(args.buf)
        end
      end,
    })
  end,
}
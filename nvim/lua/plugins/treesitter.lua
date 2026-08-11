-- nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter
-- Tree-sitter bindings for Neovim: parsing, highlighting and text objects.
return {
  "nvim-treesitter/nvim-treesitter",
  -- ATENÇÃO ao branch. O default do repo hoje é "main", que exige Neovim >= 0.12
  branch = "main",
  build = ":TSUpdate",

  event = { "BufReadPre", "BufNewFile" },

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
      -- Go Template: `helm` é o dialeto que config/filetypes.lua atribui aos
      -- templates de chart; `gotmpl` cobre o resto (.tmpl, .gotmpl).
      "helm",
      "gotmpl",
    })

    ---Liga o highlight do Tree-sitter quando existe parser para o buffer.
    ---@param bufnr integer
    local function iniciar(bufnr)
      local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

      if ok and parser then
        vim.treesitter.start(bufnr)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        iniciar(args.buf)
      end,
    })
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        iniciar(bufnr)
      end
    end
  end,
}

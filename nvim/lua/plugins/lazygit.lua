-- lazygit.nvim
-- https://github.com/kdheepak/lazygit.nvim
-- Open lazygit from Neovim: log, diff, status and staging in a floating window.
return {
  "kdheepak/lazygit.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitLog" },
  keys = {
    {
      -- NÃO usa `:LazyGit` direto. O plugin calcula a raiz do repo em
      -- project_root_dir() e joga o resultado fora (`_ = project_root_dir()`),
      -- nunca passando `-p` para o binário — então o lazygit sobe no cwd do
      -- Neovim. Com auto-session, `:cd` ou abrindo o nvim de $HOME, esse cwd
      -- não é o repositório do arquivo aberto, e o lazygit erra.
      -- Aqui a raiz é resolvida subindo do arquivo atual até o primeiro `.git`.
      "<leader>lg",
      function()
        require("util.git").lazygit()
      end,
      desc = "LazyGit (raiz do repo do arquivo atual)",
    },
  },
}

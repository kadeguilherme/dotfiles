-- gitsigns.nvim
-- https://github.com/lewis6991/gitsigns.nvim
-- Git signs in the gutter, hunk navigation/staging and inline blame.
--
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▁" },
      topdelete = { text = "▔" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged_enable = true,
    -- blame de linha sob demanda (<leader>gb); ligado sempre polui a tela e
    -- depende do updatetime (250ms, ver config/options.lua)
    current_line_blame = false,
    current_line_blame_opts = { delay = 250, virt_text_pos = "eol" },
    preview_config = { border = "rounded" },
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function map(modo, tecla, fn, desc)
        vim.keymap.set(modo, tecla, fn, { buffer = bufnr, desc = "Git: " .. desc })
      end

      -- Navegação entre hunks. `]d`/`[d` já são diagnósticos (ver coding/lsp.lua),
      -- por isso `]h`/`[h`. Em diff mode as teclas voltam ao comportamento nativo.
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Próximo hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Hunk anterior")

      -- Ações no hunk. Em modo visual agem sobre as linhas selecionadas.
      -- Com `signs_staged_enable` o stage é toggle: repetir <leader>gs sobre um
      -- hunk já staged o desfaz (é o que substitui o undo_stage_hunk, deprecado).
      map("n", "<leader>gs", gs.stage_hunk, "Stage do hunk (toggle)")
      map("n", "<leader>gr", gs.reset_hunk, "Reverter hunk")
      map("v", "<leader>gs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage da seleção")
      map("v", "<leader>gr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reverter seleção")
      map("n", "<leader>gS", gs.stage_buffer, "Stage do arquivo")
      map("n", "<leader>gR", gs.reset_buffer, "Reverter arquivo")

      -- Inspeção
      map("n", "<leader>gp", gs.preview_hunk, "Preview do hunk")
      map("n", "<leader>gb", function()
        gs.blame_line({ full = true })
      end, "Blame da linha")
      map("n", "<leader>gB", gs.toggle_current_line_blame, "Blame automático (buffer)")
      map("n", "<leader>gd", gs.diffthis, "Diff contra o índice")
      map("n", "<leader>gD", function()
        gs.diffthis("~")
      end, "Diff contra o último commit")

      -- Objeto de texto: `dih`, `vih`, ...
      map({ "o", "x" }, "ih", gs.select_hunk, "Hunk (objeto de texto)")
    end,
  },
}

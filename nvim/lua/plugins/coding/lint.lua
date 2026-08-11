-- nvim-lint
-- https://github.com/mfussenegger/nvim-lint
-- Async linting for Neovim: runs linters per filetype on save/edit.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")
    -- Ajusta as regras do yamllint para este projeto:
    -- - comentários exigem apenas 1 espaço após '#'
    -- - limite de linha aumentado para 120 caracteres
    lint.linters.yamllint.args = vim.list_extend(vim.deepcopy(lint.linters.yamllint.args), {
      "-d",
      "{extends: default, rules: {comments: {min-spaces-from-content: 1}, line-length: {max: 120}}}",
    })

    -- Linters executados automaticamente por filetype.
    -- Trivy fica fora daqui porque e um scan de seguranca mais pesado
    -- e deve ser executado manualmente via <leader>ct.
    lint.linters_by_ft = {
      terraform = { "tflint" },
      tf = { "tflint" },
      yaml = { "yamllint" },
    }

    -- Ignora buffers somente leitura (help, Telescope, plugins etc.)
    -- e respeita o toggle de desativacao por buffer.
    ---@param bufnr integer
    local function lintar(bufnr)
      if bufnr ~= vim.api.nvim_get_current_buf() then
        return
      end
      if not vim.bo[bufnr].modifiable then
        return
      end
      -- desligado via <leader>ul / <leader>un neste buffer
      if require("util.toggles").lint_desligado(bufnr) then
        return
      end
      lint.try_lint()
    end

    local grp = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true })
    -- Executa lint automaticamente em eventos comuns de edicao.
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = grp,
      callback = function(args)
        lintar(args.buf)
      end,
    })

    -- O BufReadPost do primeiro arquivo da sessao e quem carrega este plugin,
    -- entao ele ja passou quando o autocmd acima e criado.
    -- `schedule` porque o filetype so e detectado depois deste config; sem ele
    -- o try_lint nao acha linter nenhum.
    local buf_inicial = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      lintar(buf_inicial)
    end)

    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Lint: rodar no buffer" })

    local toggles = require("util.toggles")
    vim.keymap.set("n", "<leader>ul", function()
      toggles.lint()
    end, { desc = "Lint automático (buffer)" })
    vim.keymap.set("n", "<leader>un", function()
      toggles.intocavel()
    end, { desc = "Ambos: autoformat + lint (buffer)" })

    -- Trivy sob demanda: scan de segurança/misconfig (ex.: manifests do Kubernetes)
    vim.keymap.set("n", "<leader>ct", function()
      lint.try_lint("trivy")
    end, { desc = "Trivy: scan de segurança" })
  end,
}

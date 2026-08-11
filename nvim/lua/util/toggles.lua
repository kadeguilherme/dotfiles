---Toggles de "não mexer neste arquivo".
---
---Ao salvar um manifest antigo faz o
---yamlfmt reescrever o arquivo e o yamllint poluir a tela de avisos, sujando
---
---Flags lidas em plugins/conform.lua e plugins/lint.lua:
---  vim.b.disable_autoformat, vim.b.disable_lint
local M = {}

local function aviso(texto, ligado)
  vim.notify(
    texto .. ": " .. (ligado and "ligado" or "DESLIGADO"),
    ligado and vim.log.levels.INFO or vim.log.levels.WARN,
    { title = "Toggle" }
  )
end

---Apaga os diagnósticos do nvim-lint (por namespace), preservando os do LSP.
---@param bufnr integer
function M.limpar_diagnosticos_lint(bufnr)
  local ok, lint = pcall(require, "lint")
  if not ok then
    return
  end
  local nomes = vim.list_extend({ "trivy" }, lint.linters_by_ft[vim.bo[bufnr].filetype] or {})
  for _, nome in ipairs(nomes) do
    vim.diagnostic.reset(lint.get_namespace(nome), bufnr)
  end
end

---Liga/desliga o autoformat ao salvar no buffer atual.
function M.autoformat()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  aviso("Autoformat ao salvar (buffer)", not vim.b.disable_autoformat)
end

---Liga/desliga o lint automático no buffer atual.
function M.lint()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].disable_lint = not vim.b[bufnr].disable_lint
  local desligado = vim.b[bufnr].disable_lint

  if desligado then
    M.limpar_diagnosticos_lint(bufnr)
  else
    pcall(function()
      require("lint").try_lint()
    end)
  end
  aviso("Lint (buffer)", not desligado)
end

---Liga/desliga autoformat + lint no buffer: salvar não altera o arquivo.
function M.intocavel()
  local bufnr = vim.api.nvim_get_current_buf()
  -- só liga quando ambos estiverem desligados, completando um toggle parcial
  local desligar = not (vim.b[bufnr].disable_autoformat and vim.b[bufnr].disable_lint)

  vim.b[bufnr].disable_autoformat = desligar
  vim.b[bufnr].disable_lint = desligar

  if desligar then
    M.limpar_diagnosticos_lint(bufnr)
  else
    pcall(function()
      require("lint").try_lint()
    end)
  end
  aviso("Autoformat + lint neste buffer", not desligar)
end

---Liga/desliga a sugestão automática do Copilot no buffer atual.
function M.copilot()
  local ok, suggestion = pcall(require, "copilot.suggestion")
  if not ok then
    vim.notify("Copilot não está carregado", vim.log.levels.WARN, { title = "Toggle" })
    return
  end
  suggestion.toggle_auto_trigger()
  local ligado = vim.b.copilot_suggestion_auto_trigger == nil and true or vim.b.copilot_suggestion_auto_trigger
  aviso("Copilot (sugestão automática)", ligado)
end

---@param bufnr? integer
---@return boolean
function M.autoformat_desligado(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.b[bufnr].disable_autoformat == true
end

---@param bufnr? integer
---@return boolean
function M.lint_desligado(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.b[bufnr].disable_lint == true
end

return M

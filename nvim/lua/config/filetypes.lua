-- Detecta templates Helm como `helm` em vez de `yaml`.
--
-- Templates Helm não são YAML válido antes da renderização, pois contêm
-- diretivas Go Template (`{{ ... }}`) em posições onde o parser YAML espera
-- sintaxe válida. Mantê-los como `yaml` faz o yaml-language-server, yamllint e
-- yamlfmt produzirem diagnósticos falsos.
--
-- Um arquivo só é considerado Helm se estiver sob um diretório `templates/`
-- pertencente a um chart (isto é, houver um `Chart.yaml` ou `Chart.yml` no
-- diretório pai de `templates`). O Tree-sitter continua fornecendo highlight
-- através do parser `helm`.
---@param path string
---@return string|nil
local function helm_template(path)
  local dir = vim.fs.dirname(path)

  -- sobe até a pasta `templates` (o arquivo pode estar numa subpasta dela)
  while dir and vim.fs.basename(dir) ~= "templates" do
    local pai = vim.fs.dirname(dir)
    if pai == dir then
      return nil
    end
    dir = pai
  end
  if not dir then
    return nil
  end

  local chart = vim.fs.dirname(dir)
  for _, nome in ipairs({ "Chart.yaml", "Chart.yml" }) do
    if vim.uv.fs_stat(vim.fs.joinpath(chart, nome)) then
      return "helm"
    end
  end
  return nil
end

vim.filetype.add({
  pattern = {
    [".*/templates/.*%.ya?ml"] = helm_template,
    [".*/templates/.*%.tpl"] = helm_template,
  },
})

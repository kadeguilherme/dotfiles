---Rótulo curto de caminho, crescendo só o necessário para não ficar ambíguo.
---Usado por plugins/ui/bufferline.lua (mapa) e plugins/telescope.lua (por entrada).
local M = {}

-- `fnamemodify` é ponte para o Vimscript e o path_display roda por entrada
-- visível a cada tecla digitada no picker.
local cache = {}
local cache_n = 0

---@param path string
---@return string[] componentes, sem a barra da raiz
---@return string forma absoluta
local function partes(path)
  local p = cache[path]
  if not p then
    if cache_n > 4096 then -- sessão longa: reinicia em vez de crescer sem limite
      cache, cache_n = {}, 0
    end
    local abs = vim.fn.fnamemodify(path, ":p")
    p = { vim.split(abs, "/", { plain = true, trimempty = true }), abs }
    cache[path] = p
    cache_n = cache_n + 1
  end
  return p[1], p[2]
end

---@param comps string[]
---@param k integer quantos componentes finais
---@return string
local function sufixo(comps, k)
  return table.concat(comps, "/", #comps - math.min(k, #comps) + 1, #comps)
end

---Quantos caminhos da referência terminam com cada sufixo.
---Índice em vez de varrer a referência por entrada: com mil referências aquilo
---custava ~190ms por tela, e o telescope re-renderiza a cada tecla.
---@param referencia string[]
---@param piso integer
---@return table<string, integer>
local function contar_sufixos(referencia, piso)
  local contagem, vistos = {}, {}
  for _, p in ipairs(referencia) do
    if p ~= "" then
      local comps, abs = partes(p)
      if not vistos[abs] then -- caminho repetido não conta duas vezes
        vistos[abs] = true
        for k = math.min(piso, #comps), #comps do
          local s = sufixo(comps, k)
          contagem[s] = (contagem[s] or 0) + 1
        end
      end
    end
  end
  return contagem
end

-- As entradas de um mesmo render chegam com a mesma referência, então guardar
-- só a última já evita reconstruir.
local ultimo = {}

---@param a string[]|nil
---@param b string[]|nil
---@return boolean
local function mesma_lista(a, b)
  if a == b then
    return true
  end
  if a == nil or b == nil or #a ~= #b then
    return false
  end
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

---@param referencia string[]
---@param piso integer
---@return table<string, integer>
local function indice(referencia, piso)
  if ultimo.piso ~= piso or not mesma_lista(ultimo.referencia, referencia) then
    ultimo = { referencia = referencia, piso = piso, contagem = contar_sufixos(referencia, piso) }
  end
  return ultimo.contagem
end

---@param comps string[]
---@param contagem table<string, integer>
---@param piso integer
---@return string
local function menor_sufixo_unico(comps, contagem, piso)
  for k = math.min(piso, #comps), #comps do
    local s = sufixo(comps, k)
    if (contagem[s] or 0) <= 1 then -- 1 = só o próprio; 0 = fora da referência
      return s
    end
  end
  return sufixo(comps, #comps)
end

---Os `min_parts` últimos componentes ("pasta/arquivo"), crescendo até não ficar
---igual a nenhum caminho de `outros`.
---
---Em monorepo de IaC todo arquivo se chama main.tf/terragrunt.hcl e os caminhos
---divergem no MEIO, então rótulo ambíguo é confuso no telescope e perigoso no
---buffer_manager, que escolhe o buffer pelo texto renderizado.
---
---Compara em absoluto porque o telescope pode passar caminho relativo ao cwd:
---sem isso o próprio caminho não se acha na referência e o rótulo cresce até o fim.
---@param path string
---@param outros string[] caminhos com que não pode colidir
---@param min_parts? integer default 2
---@return string
function M.unique_suffix(path, outros, min_parts)
  local comps = partes(path)
  if #comps == 0 then
    return path
  end
  local piso = min_parts or 2
  return menor_sufixo_unico(comps, indice(outros, piso), piso)
end

---Rótulos de uma lista inteira de uma vez. As chaves são ABSOLUTAS: a bufferline
---indexa com `fnamemodify(buf.path, ":p")`.
---@param lista string[]
---@param min_parts? integer default 2
---@return table<string, string>
function M.unique_suffixes(lista, min_parts)
  local piso = min_parts or 2
  local contagem = indice(lista, piso)

  local saida = {}
  for _, p in ipairs(lista) do
    if p ~= "" then
      local comps, abs = partes(p)
      if saida[abs] == nil then
        saida[abs] = menor_sufixo_unico(comps, contagem, piso)
      end
    end
  end
  return saida
end

local nomes_cache, nomes_sujo = {}, true

---Buffers listados, sem `[No Name]` nem pseudo-caminho de plugin (`term://` do
---lazygit, `fugitive://`), que viram rótulo sem sentido.
---
---@return string[]
function M.listed_buffer_names()
  if not nomes_sujo then
    return nomes_cache
  end
  local nomes = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local nome = vim.api.nvim_buf_get_name(b)
    if vim.bo[b].buflisted and nome ~= "" and not nome:match("^%a[%w+.-]*://") then
      table.insert(nomes, nome)
    end
  end
  nomes_cache, nomes_sujo = nomes, false
  return nomes_cache
end

vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufFilePost" }, {
  group = vim.api.nvim_create_augroup("user_paths_buffers", { clear = true }),
  callback = function()
    nomes_sujo = true
  end,
})
vim.api.nvim_create_autocmd("OptionSet", {
  group = "user_paths_buffers",
  pattern = "buflisted",
  callback = function()
    nomes_sujo = true
  end,
})

return M

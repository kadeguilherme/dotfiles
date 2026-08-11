-- Caminho exibido a partir da RAIZ DO REPOSITÓRIO, não do cwd.
--
-- `path = 1` mostra o caminho relativo ao cwd: abrindo o nvim de ~/git, um
-- arquivo de monorepo aparecia como sensedia/sensedia-infrastructure/...
-- Aqui a base é o primeiro `.git` subindo do diretório do arquivo.

-- vim.fs.find é caro e a statusline redesenha a cada movimento do cursor;
-- o resultado fica em cache por buffer, revalidado pelo nome do arquivo.
local cache = {}

---@param arquivo string
---@return string|nil
local function raiz_do_repo(arquivo)
  local achado = vim.fs.find({ ".git" }, {
    upward = true,
    path = vim.fs.dirname(arquivo),
    limit = 1,
  })[1]
  -- `.git` é diretório no clone normal e arquivo em worktree/submódulo; o pai
  -- é a raiz nos dois casos, então não filtramos por type.
  return achado and vim.fs.dirname(achado) or nil
end

---Corta as pastas do começo e marca o corte com `..`, preservando inteiras as
---últimas que couberem — as que identificam o arquivo em monorepo de IaC.
---@param rel string
---@param orcamento integer
---@return string
local function encurtar(rel, orcamento)
  if vim.fn.strdisplaywidth(rel) <= orcamento then
    return rel
  end

  local partes = vim.split(rel, "/", { plain = true, trimempty = true })

  -- Pega o MAIOR número de componentes finais que cabe, até 1: um piso rígido
  -- de 3 estourava o orçamento em janela estreita e o lualine cortava a âncora.
  for k = #partes - 1, 1, -1 do
    local texto = "../" .. table.concat(vim.list_slice(partes, #partes - k + 1, #partes), "/")
    if vim.fn.strdisplaywidth(texto) <= orcamento then
      return texto
    end
  end

  -- nem o nome do arquivo sozinho cabe; devolve ele e deixa o lualine cortar
  return partes[#partes]
end

local ICONE_REPO = "" -- octicon repo (U+F401)
local ICONE_DIR = "" -- pasta (U+F07B), usado quando não há repositório

-- Mínimo de espaço para a âncora valer a pena; abaixo disso é omitida — um
-- nome cortado no meio ("sensedia-infrastructure" → "<structure") não informa
-- nada, e a cauda do caminho identifica o arquivo melhor.
local MIN_CAMINHO = 30

-- Largura das demais seções, fora a âncora e o branch: 11 (modo) + 27
-- (encoding, fileformat, filetype, progresso, posição) = 38.
local OVERHEAD = 38

---Largura do branch com ícone e espaços. Precisa ser medida: é a peça de
---largura mais variável da linha, e um branch de 32 caracteres estourava o
---orçamento fixo, cortando a âncora no meio.
---@return integer
local function largura_branch()
  local b = vim.b.gitsigns_head or vim.g.gitsigns_head
  if not b or b == "" then
    return 0
  end
  return vim.fn.strdisplaywidth(tostring(b)) + 3
end

---Nome do repo e caminho relativo à raiz, calculados juntos e em cache.
---@return table { repo = string, rel = string }
local function dados()
  local bufnr = vim.api.nvim_get_current_buf()
  local arquivo = vim.api.nvim_buf_get_name(bufnr)

  local c = cache[bufnr]
  if c and c.arquivo == arquivo then
    return c
  end

  c = { arquivo = arquivo, repo = "", icone = "", rel = "" }
  if arquivo == "" then
    c.rel = "[sem nome]"
  else
    local root = raiz_do_repo(arquivo)
    if root then
      c.repo = vim.fs.basename(root)
      c.icone = ICONE_REPO
      c.rel = vim.fs.relpath(root, arquivo) or vim.fn.fnamemodify(arquivo, ":t")
    else
      -- Sem `.git` acima: usa o cwd como âncora, com ícone de PASTA em vez do de
      -- repositório, para o rótulo não sugerir um repo que não existe.
      local cwd = vim.uv.cwd()
      local rel = cwd and vim.fs.relpath(cwd, arquivo)
      if rel then
        c.repo = vim.fs.basename(cwd)
        c.icone = ICONE_DIR
        c.rel = rel
      else
        -- fora do cwd também: não há âncora honesta, mostra o caminho inteiro
        c.rel = vim.fn.fnamemodify(arquivo, ":~")
      end
    end
  end

  cache[bufnr] = c
  return c
end

---Texto da âncora (nome do repo, ou do cwd quando não há repo). "" = omitido.
---Mostra apenas se sobra espaço de fato, descontando o branch — um limite fixo
---por largura de janela estourava com branch longo e cortava a âncora no meio.
local function texto_repo()
  local c = dados()
  if c.repo == "" then
    return ""
  end
  local rotulo = c.icone .. " " .. c.repo
  local sobra = vim.o.columns - OVERHEAD - largura_branch() - vim.fn.strdisplaywidth(rotulo) - 1
  if sobra < MIN_CAMINHO then
    return ""
  end
  return rotulo
end

---Componente do nome do repositório. String vazia = componente omitido.
local function repo()
  return texto_repo()
end

local function caminho()
  local c = dados()

  -- A âncora divide a seção com o caminho, e o branch ocupa a mesma linha —
  -- os dois saem do orçamento.
  local r = texto_repo()
  local reservado = OVERHEAD + largura_branch()
  if r ~= "" then
    reservado = reservado + vim.fn.strdisplaywidth(r) + 1
  end
  local texto = encurtar(c.rel, math.max(24, vim.o.columns - reservado))

  -- Sem marca de "não salvo": o bufferline já marca o buffer modificado com ●;
  -- duas marcas para o mesmo estado é ruído. A de somente-leitura fica (a barra
  -- de abas não mostra essa).
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then
    return texto .. " "
  end
  return texto
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = vim.api.nvim_create_augroup("user_lualine_cache", { clear = true }),
  callback = function(ev)
    cache[ev.buf] = nil
  end,
})

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = "",
      section_separators = "",
      -- no dashboard a statusline só mostra ruído ([No Name], 48%, 13:39)
      disabled_filetypes = { statusline = { "alpha" } },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        -- repo em tom de comentário: é contexto, não a identidade do arquivo.
        { repo, color = "Comment" },
        caminho,
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}

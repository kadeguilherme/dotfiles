-- Caminho exibido a partir da RAIZ DO REPOSITÓRIO, não do cwd.
--
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
---@param rel string
---@param orcamento integer
---@return string
local function encurtar(rel, orcamento)
	if vim.fn.strdisplaywidth(rel) <= orcamento then
		return rel
	end

	local partes = vim.split(rel, "/", { plain = true, trimempty = true })

	for k = #partes - 1, 1, -1 do
		local texto = "../" .. table.concat(vim.list_slice(partes, #partes - k + 1, #partes), "/")
		if vim.fn.strdisplaywidth(texto) <= orcamento then
			return texto
		end
	end

	-- nem o nome do arquivo sozinho cabe; devolve ele e deixa o lualine cortar
	return partes[#partes]
end

local ICONE_REPO = ""
local ICONE_DIR = ""

local MIN_CAMINHO = 30

-- filetype, progresso, posição). Medido em 39 com filetype curto.
local OVERHEAD = 38

---@return integer
local function largura_reservada()
	local bufnr = vim.api.nvim_get_current_buf()
	local total = OVERHEAD

	local ok, gb = pcall(require, "lualine.components.branch.git_branch")
	local branch = ok and gb.get_branch(bufnr) or ""
	if branch ~= "" then
		total = total + vim.fn.strdisplaywidth(branch) + 4 -- ícone + padding
	end

	-- ícone + número + espaço, por severidade presente
	for _, n in pairs(vim.diagnostic.count(bufnr)) do
		total = total + #tostring(n) + 3
	end

	-- mesmas chaves que alimentam o componente `diff` (ver `source` lá embaixo)
	local d = vim.b[bufnr].gitsigns_status_dict
	if d then
		for _, chave in ipairs({ "added", "changed", "removed" }) do
			local n = d[chave] or 0
			if n > 0 then
				total = total + #tostring(n) + 3
			end
		end
	end

	return total
end

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

local function texto_repo()
	local c = dados()
	if c.repo == "" then
		return ""
	end
	local rotulo = c.icone .. " " .. c.repo
	local sobra = vim.o.columns - largura_reservada() - vim.fn.strdisplaywidth(rotulo) - 1
	if sobra < MIN_CAMINHO then
		return ""
	end
	return rotulo
end

local function caminho()
	local c = dados()

	-- A âncora divide a seção com o caminho, e o branch ocupa a mesma linha —
	-- os dois saem do orçamento.
	local r = texto_repo()
	local reservado = largura_reservada()
	if r ~= "" then
		reservado = reservado + vim.fn.strdisplaywidth(r) + 1
	end
	-- piso baixo: encurtar até o nome do arquivo é melhor que estourar a linha
	local texto = encurtar(c.rel, math.max(8, vim.o.columns - reservado))

	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then
		return "%<" .. texto .. " "
	end
	return "%<" .. texto
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "DirChanged" }, {
	group = vim.api.nvim_create_augroup("user_lualine_cache", { clear = true }),
	callback = function(ev)
		if ev.event == "DirChanged" then
			cache = {}
		else
			cache[ev.buf] = nil
		end
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
			lualine_b = {
				"branch",
				{
					"diff",
					source = function()
						local d = vim.b.gitsigns_status_dict
						if d then
							return { added = d.added, modified = d.changed, removed = d.removed }
						end
					end,
				},
				"diagnostics",
			},
			lualine_c = {
				{ texto_repo, color = "Comment" },
				caminho,
			},
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}

local M = {}

---Roda git dentro de `root`. Devolve stdout sem espaços nas pontas, ou nil+erro.
---@param root string
---@param args string[]
---@param stdin? string conteúdo para o stdin (usado no blame de buffer modificado)
---@return string|nil saida, string|nil erro
local function git(root, args, stdin)
	local cmd = { "git", "-C", root }
	vim.list_extend(cmd, args)
	local res = vim.system(cmd, { text = true, stdin = stdin }):wait()
	if res.code ~= 0 then
		return nil, vim.trim(res.stderr or "git falhou")
	end
	return vim.trim(res.stdout or "")
end

--------------------------------------------------------------------------------
-- Raiz do repositório
--------------------------------------------------------------------------------

---Sobe o diretório procurando o primeiro `.git`, começando pelo arquivo dado.
---@param path? string caminho de arquivo ou diretório de partida
---@return string|nil raiz
function M.root(path)
	local partida
	if path and path ~= "" then
		partida = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
	else
		partida = vim.uv.cwd()
	end

	local achado = vim.fs.find(".git", { upward = true, path = partida, limit = 1 })[1]
	if achado then
		return vim.fs.dirname(achado)
	end

	-- último recurso: o cwd pode estar num repo mesmo que o arquivo não esteja
	if partida ~= vim.uv.cwd() then
		achado = vim.fs.find(".git", { upward = true, path = vim.uv.cwd(), limit = 1 })[1]
		if achado then
			return vim.fs.dirname(achado)
		end
	end
	return nil
end

---Raiz do repositório do buffer informado.
---@param bufnr? integer
---@return string|nil
function M.buf_root(bufnr)
	return M.root(vim.api.nvim_buf_get_name(bufnr or 0))
end

--------------------------------------------------------------------------------
-- Remote → forge
--------------------------------------------------------------------------------

-- Cada forge monta a URL de um jeito.
local FORGES = {
	github = { commit = "/commit/%s", pr = "/pull/%s", linha = "/blob/%s/%s#L%d" },
	bitbucket = { commit = "/commits/%s", pr = "/pull-requests/%s", linha = "/src/%s/%s#lines-%d" },
}

---@param url string
---@return string|nil host, string|nil caminho ("owner/repo")
local function parse_remote(url)
	local host, caminho

	-- git@host:owner/repo.git  (scp-like, o formato mais comum em chave SSH)
	host, caminho = url:match("^[%w%._%-]+@([^:/]+):(.+)$")

	if not host then
		-- ssh://git@host:2222/owner/repo.git  (com userinfo)
		-- Lua não tem grupo opcional, então são dois padrões: este EXIGE o "@".
		-- Num único padrão com "@?", o trecho anterior consome o host inteiro por
		-- ser guloso e sobra só a última letra ("github.com" virava "m").
		host, caminho = url:match("^%a[%w%+%.%-]*://[^/]*@([^:/]+):?%d*/(.+)$")
	end

	if not host then
		-- https://host/owner/repo.git  (sem userinfo)
		host, caminho = url:match("^%a[%w%+%.%-]*://([^:/]+):?%d*/(.+)$")
	end

	if not host then
		return nil
	end
	caminho = caminho:gsub("%.git$", ""):gsub("^/+", ""):gsub("/+$", "")
	return host, caminho
end

---Descobre o padrão de URL do forge pelo host. Hosts self-hosted não batem com
---o nome exato, então caímos para uma heurística pelo nome do host.
---@param host string
---@return table
local function forge_de(host)
	if host:find("bitbucket", 1, true) then
		return FORGES.bitbucket
	end
	return FORGES.github
end

---@param root string
---@return table|nil info { base = "https://host/owner/repo", forge = FORGES.x }
local function remote_info(root)
	-- prefere o upstream do branch atual; cai para origin
	local remote
	local upstream = git(root, { "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
	if upstream and upstream ~= "" then
		remote = upstream:match("^([^/]+)/")
	end
	local url = git(root, { "remote", "get-url", remote or "origin" })
	if not url or url == "" then
		url = git(root, { "remote", "get-url", "origin" })
	end
	if not url or url == "" then
		return nil
	end

	local host, caminho = parse_remote(url)
	if not host then
		return nil
	end
	return {
		base = "https://" .. host .. "/" .. caminho,
		forge = forge_de(host),
	}
end

--------------------------------------------------------------------------------
-- Blame da linha
--------------------------------------------------------------------------------

---Commit que tocou a linha por último.
---
---Quando o buffer tem alteração não salva, o blame roda com `--contents -`
---recebendo o texto do BUFFER. Sem isso, o git leria o arquivo do disco e os
---números de linha não corresponderiam ao que você está vendo na tela.
---@param bufnr? integer
---@param lnum? integer
---@return table|nil info { sha, root, autor, data, assunto }, string|nil erro
function M.blame_line(bufnr, lnum)
	bufnr = bufnr or 0
	local arquivo = vim.api.nvim_buf_get_name(bufnr)
	if arquivo == "" then
		return nil, "este buffer não é um arquivo"
	end

	local root = M.root(arquivo)
	if not root then
		return nil, "arquivo não está em um repositório git"
	end

	lnum = lnum or vim.fn.line(".")
	local args = { "blame", "-L", lnum .. "," .. lnum, "--porcelain" }
	local stdin
	if vim.bo[bufnr].modified then
		table.insert(args, "--contents")
		table.insert(args, "-")
		stdin = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
	end
	vim.list_extend(args, { "--", arquivo })

	local saida, erro = git(root, args, stdin)
	if not saida then
		return nil, erro
	end

	local sha = saida:match("^(%x+)")
	if not sha then
		return nil, "não foi possível ler o blame desta linha"
	end
	if sha:match("^0+$") then
		return nil, "esta linha ainda não foi commitada"
	end

	local detalhe = git(root, { "log", "-1", "--format=%an%x00%ad%x00%s", "--date=short", sha })
	local autor, data, assunto = "?", "?", "?"
	if detalhe then
		autor, data, assunto = detalhe:match("^(.-)%z(.-)%z(.*)$")
	end

	return { sha = sha, root = root, autor = autor, data = data, assunto = assunto }
end

--------------------------------------------------------------------------------
-- PR que introduziu o commit
--------------------------------------------------------------------------------

---Número do pull request que trouxe `sha` para a linha principal.
---
---Estratégia, sem depender de CLI autenticado (o `gh` só serve para GitHub, e
---os repos de trabalho aqui são Bitbucket):
---  1. Acha o merge commit no caminho de ancestralidade entre `sha` e HEAD. O
---     mais ANTIGO desses é o merge do PR. Cobre o formato do Bitbucket
---     ("Merged in branch (pull request #504)") e o do GitHub
---     ("Merge pull request #12 from ...").
---  2. Se o repo usa squash merge não existe merge commit, mas o assunto do
---     próprio commit normalmente termina com "(#123)".
---@param root string
---@param sha string
---@return string|nil numero, string|nil como
function M.pr_number(root, sha)
	local saida = git(root, { "log", "--merges", "--ancestry-path", "--format=%s", sha .. "..HEAD" })
	if saida and saida ~= "" then
		local linhas = vim.split(saida, "\n", { trimempty = true })
		local mais_antigo = linhas[#linhas] -- log vem do mais novo pro mais antigo
		local n = mais_antigo:match("[Pp]ull [Rr]equest #(%d+)")
		if n then
			return n, "merge commit"
		end
	end

	local assunto = git(root, { "log", "-1", "--format=%s", sha })
	if assunto then
		local n = assunto:match("%(#(%d+)%)%s*$") or assunto:match("#(%d+)%s*$")
		if n then
			return n, "assunto do commit (squash)"
		end
	end

	return nil
end

--------------------------------------------------------------------------------
-- Ações para keymap
--------------------------------------------------------------------------------

local function aviso(msg, nivel)
	vim.notify(msg, nivel or vim.log.levels.WARN, { title = "git" })
end

---Abre no navegador o commit que tocou a linha atual.
function M.open_commit()
	local info, erro = M.blame_line()
	if not info then
		return aviso(erro)
	end

	local remoto = remote_info(info.root)
	if not remoto then
		return aviso("não achei um remote utilizável neste repositório")
	end

	local url = remoto.base .. remoto.forge.commit:format(info.sha)
	vim.notify(
		("%s — %s, %s\n%s"):format(info.sha:sub(1, 8), info.autor, info.data, info.assunto),
		vim.log.levels.INFO,
		{ title = "abrindo commit" }
	)
	vim.ui.open(url)
end

---Abre no navegador o PR que introduziu a linha atual.
function M.open_pr()
	local info, erro = M.blame_line()
	if not info then
		return aviso(erro)
	end

	local remoto = remote_info(info.root)
	if not remoto then
		return aviso("não achei um remote utilizável neste repositório")
	end

	local numero, como = M.pr_number(info.root, info.sha)
	if not numero then
		aviso(
			("não achei PR para o commit %s.\nAbrindo o commit no lugar."):format(info.sha:sub(1, 8)),
			vim.log.levels.INFO
		)
		vim.ui.open(remoto.base .. remoto.forge.commit:format(info.sha))
		return
	end

	vim.notify(
		("PR #%s (via %s)\ncommit %s — %s"):format(numero, como, info.sha:sub(1, 8), info.autor),
		vim.log.levels.INFO,
		{ title = "abrindo PR" }
	)
	vim.ui.open(remoto.base .. remoto.forge.pr:format(numero))
end

---Copia (registrador + e ") o permalink da linha atual, fixado no SHA do
---commit atual — link que não quebra quando a branch avança.
function M.yank_permalink()
	local arquivo = vim.api.nvim_buf_get_name(0)
	if arquivo == "" then
		return aviso("este buffer não é um arquivo")
	end
	local root = M.root(arquivo)
	if not root then
		return aviso("arquivo não está em um repositório git")
	end
	local remoto = remote_info(root)
	if not remoto then
		return aviso("não achei um remote utilizável neste repositório")
	end

	local sha = git(root, { "rev-parse", "HEAD" })
	if not sha then
		return aviso("não consegui resolver o HEAD")
	end

	local relativo = vim.fs.relpath(root, arquivo) or vim.fn.fnamemodify(arquivo, ":t")
	local url = remoto.base .. remoto.forge.linha:format(sha, relativo, vim.fn.line("."))

	vim.fn.setreg("+", url)
	vim.fn.setreg('"', url)
	vim.notify(url, vim.log.levels.INFO, { title = "permalink copiado" })
end

---Abre o lazygit na raiz do repositório do arquivo atual.
---O `:LazyGit` do plugin não passa `-p`, então ele herda o cwd do Neovim — que
---muitas vezes não é o repositório do arquivo aberto (ou não é repo nenhum).
function M.lazygit()
	local root = M.buf_root()
	if not root then
		return aviso("nenhum repositório git encontrado a partir deste arquivo nem do cwd")
	end
	require("lazygit").lazygit(root)
end

return M

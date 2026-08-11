-- nvim-lspconfig
-- https://github.com/neovim/nvim-lspconfig
-- LSP configuration: servers, diagnostics and LSP keymaps.
return {

	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "mason-org/mason-lspconfig.nvim", dependencies = { "mason-org/mason.nvim" } },
		"saghen/blink.cmp",
		"b0o/SchemaStore.nvim", -- catálogo de schemas JSON/YAML (k8s, compose, gh actions, ...)
	},
	config = function()
		-- Configuração por server. A chave é o nome do server no lspconfig/mason.
		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME },
						},
						diagnostics = { globals = { "vim" } },
						hint = { enable = true }, -- inlay hints
						format = { enable = false }, -- deixa a formatação pro stylua (conform)
					},
				},
			},
			bashls = {},
			jsonls = {},
			yamlls = {
				settings = {
					yaml = {
						keyOrdering = false,
						-- desliga o catálogo interno do server e usa o do SchemaStore.nvim
						schemaStore = { enable = false, url = "" },
						schemas = vim.tbl_extend("force", require("schemastore").yaml.schemas(), {
							-- Schema do Kubernetes fixado na versão do cluster (1.36).
							-- variante "-strict" = reclama de campos desconhecidos (pega typos);
							-- remova o "-strict" se CRDs (Istio, ArgoCD, ...) derem falso positivo.
							-- AJUSTE os globs abaixo para o layout dos seus projetos.
							["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.36.0-standalone-strict/all.json"] = {
								"k8s/**/*.yaml",
								"manifests/**/*.yaml",
								"*.k8s.yaml",
							},
						}),
					},
				},
			},
			-- Helm. Anexa ao filetype `helm` (ver lua/config/filetypes.lua), entende
			-- Go template, resolve `.Values.*` a partir do values.yaml e faz hover nos
			-- helpers do _helpers.tpl.
			helm_ls = {
				settings = {
					["helm-ls"] = {
						-- O helm-ls renderiza o template e só então passa o YAML resultante
						-- ao yaml-language-server — por isso aqui ele é utilizável, enquanto
						-- anexá-lo direto ao template gerava 1981 erros.
						yamlls = {
							enabled = true,
							path = "yaml-language-server",
							diagnosticsLimit = 50,
							showDiagnosticsDirectly = false,
							-- validate = false mata só os DIAGNÓSTICOS do yamlls, mantendo
							-- completion e hover dele. Motivo: chart que gera kinds diferentes
							-- em ramos do mesmo arquivo (Deployment vs Argo Rollout) nunca casa
							-- com um único schema — o ramo não escolhido acusa erro falso.
							-- Troque para true se quiser validação de schema e aceitar isso.
							-- Manifests k8s comuns (k8s/**, manifests/**) seguem validados
							-- pelo yamlls normal; e o helmLint abaixo continua ativo.
							config = { validate = false },
						},
						valuesFiles = {
							mainValuesFile = "values.yaml",
							additionalValuesFilesGlobPattern = "values*.yaml",
						},
						helmLint = { enabled = true },
					},
				},
			},
			gopls = {
				settings = {
					gopls = {
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						analyses = { unusedparams = true, nilness = true },
						staticcheck = true,
					},
				},
			},
			terraformls = {
				init_options = {
					ignoreSingleFileWarning = true,
				},
				on_attach = function(_, bufnr)
					if vim.lsp.codelens.enable then
						vim.lsp.codelens.enable(true, { bufnr = bufnr })
					else
						vim.lsp.codelens.refresh({ bufnr = bufnr })
						vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
							buffer = bufnr,
							group = vim.api.nvim_create_augroup("user_codelens_" .. bufnr, { clear = true }),
							callback = function()
								vim.lsp.codelens.refresh({ bufnr = bufnr })
							end,
						})
					end
				end,
			},
			pyright = {
				settings = {
					pyright = {
						-- deixa a organização de imports pro Ruff
						disableOrganizeImports = true,
					},
				},
			},
			ruff = {}, -- lint + format de Python (server separado do pyright)
		}

		-- Capabilities do blink.cmp aplicadas a TODOS os servers
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		vim.lsp.config("*", { capabilities = capabilities })

		-- Aplica a config de cada server (mescla com a de "*" acima)
		for name, cfg in pairs(servers) do
			vim.lsp.config(name, cfg)
		end

		-- Mason instala os servers e o mason-lspconfig chama vim.lsp.enable() por baixo.
		-- automatic_enable recebe a lista explícita, e não `true`: com `true` ele habilita
		-- QUALQUER pacote instalado no Mason que case com um nome de server do lspconfig —
		-- e o lspconfig tem um `lsp/stylua.lua`, então o stylua (que aqui é só formatter
		-- do conform) subia como LSP em todo buffer Lua e morria com erro no shutdown.
		local server_names = vim.tbl_keys(servers)
		require("mason-lspconfig").setup({
			ensure_installed = server_names,
			automatic_enable = server_names,
		})

		-- Diagnósticos
		vim.diagnostic.config({
			virtual_text = { spacing = 2, prefix = "●" },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = " ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = { border = "rounded", source = true },
		})

		-- Keymaps quando um LSP anexa a um buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
			callback = function(event)
				local function map(keys, fn, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				local tb = require("telescope.builtin")
				map("gd", tb.lsp_definitions, "Ir para definição")
				map("gr", tb.lsp_references, "Referências")
				map("gI", tb.lsp_implementations, "Implementações")
				map("gy", tb.lsp_type_definitions, "Definição de tipo")
				map("gD", vim.lsp.buf.declaration, "Declaração")
				map("K", vim.lsp.buf.hover, "Hover / documentação")
				map("<leader>cr", vim.lsp.buf.rename, "Renomear símbolo")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
				map("<leader>cd", vim.diagnostic.open_float, "Diagnóstico da linha")
				map("<leader>cs", tb.lsp_document_symbols, "Símbolos do documento")
				map("[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Diagnóstico anterior")
				map("]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Próximo diagnóstico")

				-- Inlay hints com toggle (se o server suportar)
				-- defauft: false para nao mostra
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
					map("<leader>ch", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
							{ bufnr = event.buf }
						)
					end, "Alternar inlay hints")
				end
			end,
		})
	end,
}

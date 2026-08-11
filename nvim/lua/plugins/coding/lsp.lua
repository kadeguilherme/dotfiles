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
      jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },
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
      },
      pyright = {
        settings = {
          pyright = {
            -- deixa a organização de imports pro Ruff
            disableOrganizeImports = true,
          },
        },
      },
      -- lint + format de Python (server separado do pyright)
      ruff = {
        -- O pyright cuida de hover/documentação. Sem isto os dois servers
        -- respondem `textDocument/hover` e o K abre a doc duplicada.
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      },
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
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
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

        -- Pickers do Telescope resolvidos NA TECLA, não aqui: `require` no
        -- corpo do LspAttach aborta o callback inteiro se o telescope não
        -- estiver disponível (nenhum keymap abaixo seria criado) e força o
        -- load dele no primeiro arquivo aberto, matando o lazy-load.
        ---@param builtin string picker de `telescope.builtin`
        ---@param fallback function equivalente nativo do vim.lsp.buf
        local function pick(builtin, fallback)
          return function()
            local ok, tb = pcall(require, "telescope.builtin")
            if ok and tb[builtin] then
              tb[builtin]()
            else
              fallback()
            end
          end
        end

        map("gd", pick("lsp_definitions", vim.lsp.buf.definition), "Ir para definição")
        -- `grr` e não `gr`: mapear o prefixo puro faz os nativos (grn, gra,
        -- gri, grt) esperarem o timeoutlen
        map("grr", pick("lsp_references", vim.lsp.buf.references), "Referências")
        map("gI", pick("lsp_implementations", vim.lsp.buf.implementation), "Implementações")
        map("gy", pick("lsp_type_definitions", vim.lsp.buf.type_definition), "Definição de tipo")
        map("K", vim.lsp.buf.hover, "Hover / documentação")
        map("<leader>cr", vim.lsp.buf.rename, "Renomear símbolo")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
        map("<leader>cd", vim.diagnostic.open_float, "Diagnóstico da linha")
        map("<leader>cs", pick("lsp_document_symbols", vim.lsp.buf.document_symbol), "Símbolos do documento")
        map("[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Diagnóstico anterior")
        map("]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Próximo diagnóstico")

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- `textDocument/declaration` é raro (gopls, lua_ls e pyright não
        -- implementam); só mapeia gD onde o server realmente responde.
        if client and client:supports_method("textDocument/declaration") then
          map("gD", vim.lsp.buf.declaration, "Declaração")
        end

        -- Codelens: terraformls (init/validate) e gopls (run test, generate, tidy).
        if client and client:supports_method("textDocument/codeLens") then
          if vim.lsp.codelens.enable then
            -- Neovim >= 0.12: o próprio core cuida do refresh
            vim.lsp.codelens.enable(true, { bufnr = event.buf })
          else
            -- 0.11.x: refresh manual nos eventos de edição
            vim.lsp.codelens.refresh({ bufnr = event.buf })
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
              buffer = event.buf,
              group = vim.api.nvim_create_augroup("user_codelens_" .. event.buf, { clear = true }),
              callback = function()
                vim.lsp.codelens.refresh({ bufnr = event.buf })
              end,
            })
          end
          map("<leader>cc", function()
            vim.lsp.codelens.run()
          end, "Rodar codelens")
        end

        -- Inlay hints com toggle (se o server suportar)
        -- defauft: false para nao mostra
        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
          map("<leader>ch", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
          end, "Alternar inlay hints")
        end
      end,
    })
  end,
}

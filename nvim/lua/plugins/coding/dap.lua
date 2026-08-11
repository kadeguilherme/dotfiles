-- nvim-dap
-- https://github.com/mfussenegger/nvim-dap
-- Debug Adapter Protocol client: breakpoints, stepping and REPL.
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    "theHamsta/nvim-dap-virtual-text",
    -- sem `ft`: o lazy força as dependências junto do pai, e o config chama
    -- dap-go.setup() sem condicional
    "leoluz/nvim-dap-go",
  },
  -- Grupo <leader>d = Debug
  keys = {
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug: breakpoint",
    },
    {
      "<leader>dB",
      function()
        -- Esc/vazio devolve "", que criaria um breakpoint incondicional calado
        local cond = vim.fn.input("Condição do breakpoint: ")
        if cond ~= "" then
          require("dap").set_breakpoint(cond)
        end
      end,
      desc = "Debug: breakpoint condicional",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Debug: continuar/iniciar",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: step into",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: step over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: step out",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Debug: REPL",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Debug: rodar último",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Debug: terminar",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Debug: alternar UI",
    },
    {
      "<leader>de",
      function()
        require("dapui").eval()
      end,
      mode = { "n", "v" },
      desc = "Debug: avaliar expressão",
    },
    -- Go (delve)
    {
      "<leader>dgt",
      function()
        require("dap-go").debug_test()
      end,
      desc = "Debug: teste Go sob o cursor",
    },
    {
      "<leader>dgl",
      function()
        require("dap-go").debug_last_test()
      end,
      desc = "Debug: último teste Go",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()
    require("dap-go").setup() -- configura o adapter do delve (dlv) automaticamente

    -- Python: o `debugpy-adapter` vem do mason (ver coding/mason.lua). O guard
    -- evita registrar um adapter quebrado antes de o mason instalar.
    local debugpy = vim.fn.exepath("debugpy-adapter")
    if debugpy ~= "" then
      dap.adapters.python = { type = "executable", command = debugpy }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Arquivo atual",
          program = "${file}",
          console = "integratedTerminal",
          justMyCode = false,
        },
      }
    end

    -- Abre/fecha a UI junto com a sessão de debug
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Sinais na gutter
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })
  end,
}

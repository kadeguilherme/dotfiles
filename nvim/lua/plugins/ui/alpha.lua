-- alpha-nvim
-- https://github.com/goolord/alpha-nvim
-- Dashboard/start screen for Neovim with a header, menu and footer.
return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header (Kermit + balão cowsay)
    dashboard.section.header.val = {
      [[ ___________________________   ]],
      [[< hop in, it's all keyboard >  ]],
      [[ ---------------------------   ]],
      [[       \                       ]],
      [[        \      (o)(o)          ]],
      [[         \    /  ~~  \         ]],
      [[              \ (__) /         ]],
      [[               <\/\/>          ]],
    }

    -- Set menu (alinhado com os keymaps reais desta config)
    dashboard.section.buttons.val = {
      dashboard.button("n", "󰈤  > New File", "<cmd>ene<CR>"),
      dashboard.button("e", "󰉋  > Open file manager (yazi)", "<cmd>Yazi<CR>"),
      dashboard.button("ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("fg", "  > Live Grep", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("fr", "󰥔  > Recent Files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("wr", "󰁯  > Restore Session For Current Directory", "<cmd>AutoSession restore<CR>"),
      dashboard.button("l", "  > Plugins (Lazy)", "<cmd>Lazy<CR>"),
      dashboard.button("q", "󰐥  > Quit NVIM", "<cmd>qa<CR>"),
    }

    -- Footer: nº de plugins carregados + tempo de startup (via lazy.nvim)
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "⚡ "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins carregados em "
          .. ms
          .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- No buffer do alpha: sem fold e sem tabline/bufferline (dashboard limpo)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.opt_local.foldenable = false

        -- esconde a tabline enquanto o dashboard estiver aberto...
        local prev_showtabline = vim.opt.showtabline:get()
        vim.opt.showtabline = 0

        -- ...e restaura quando sair do dashboard
        vim.api.nvim_create_autocmd("BufUnload", {
          buffer = 0,
          once = true,
          callback = function()
            vim.opt.showtabline = prev_showtabline
          end,
        })
      end,
    })
  end,
}

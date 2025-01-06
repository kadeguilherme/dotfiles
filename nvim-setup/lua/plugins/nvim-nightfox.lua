-------------------------------------------------
-- name : nightfox.nvim
-- url  : https://github.com/EdenEast/nightfox.nvim
-------------------------------------------------
return {
    "EdenEast/nightfox.nvim",
    lazy = false,
    config = function ()
      -- Configurações específicas do Nightfox
      require('nightfox').setup({
        options = {
          dim_inactive = true,  -- Define que painéis não focados não terão fundo alternativo
          transparent = false,   -- Se false, o fundo não será transparente
          terminal_colors = true, -- Ativa cores no terminal
          -- Outras configurações podem ir aqui, conforme necessário
        },
      })
      vim.cmd("colorscheme carbonfox")

    end
  }

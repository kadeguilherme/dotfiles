-------------------------------------------------
-- name : nightfox.nvim
-- url  : https://github.com/EdenEast/nightfox.nvim
-------------------------------------------------
return {
    "EdenEast/nightfox.nvim",
    lazy = false,
    config = function ()
        vim.cmd("colorscheme carbonfox")
    end 
  }
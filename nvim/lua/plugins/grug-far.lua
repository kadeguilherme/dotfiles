return {
  "MagicDuck/grug-far.nvim",

  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open()
      end,
      desc = "Search and Replace",
    },
  },

  config = function()
    require("grug-far").setup({
      -- suas opções aqui
    })
  end,
}

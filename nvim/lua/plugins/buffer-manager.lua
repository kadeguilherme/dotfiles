return {
  "j-morano/buffer_manager.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>bb",
      function()
        require("buffer_manager.ui").toggle_quick_menu()
      end,
      desc = "Buffer menu",
    },
  },
  opts = {
    loop_nav = true,
    short_file_names = false,
    short_term_names = true,
    focus_alternate_buffer = false,

    width = 0.7,

    format_function = function(bufname)
      local paths = require("util.paths")
      return paths.unique_suffix(bufname, paths.listed_buffer_names(), 2)
    end,

    -- dentro do menu: abrir o buffer selecionado em split/vsplit
    select_menu_item_commands = {
      v = { key = "<C-v>", command = "vsplit" },
      h = { key = "<C-h>", command = "split" },
    },
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  },
}

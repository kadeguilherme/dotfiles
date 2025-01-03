-------------------------------------------------
-- name : vim-tmux-navigator
-- url  : https://github.com/christoomey/vim-tmux-navigator
-----------------------------------------------
return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
          },
        },
        pickers = {
			    find_files = {
				    theme = "dropdown",
				    previewer = false,
				    hidden = true,
			    },
			    live_grep = {
				    --theme = "dropdown",
				    --previewer = true,
            --layout_strategy = "horizontal",
            preview_width = 0.6,
			    },
			    buffers = {
				    theme = "dropdown",
				    previewer = false,
			    },
		    },
      })
      vim.keymap.set('n', '<leader>ff', builtin.find_files,{ desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leaer>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>fr', builtin.git_branches, { desc = 'Telescope git branches' })

      telescope.load_extension("ui-select")
    end,
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
  },
}

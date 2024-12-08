-------------------------------------------------
-- name : telescope
-- url  : https://github.com/nvim-telescope/telescope.nvim
-------------------------------------------------

local mapkey = require("util.keymapper").mapkey

local config = function()
	local telescope = require("telescope")
	telescope.setup({
		defaults = {
			mappings = {
				i = {
					["<C-j>"] = "move_selection_next",
					["<C-k>"] = "move_selection_previous",
				},
			},
		},
		pickers = {
			find_files = {
				theme = "dropdown",
				previewer = false,
				hidden = true,
			},
			live_grep = {
				theme = "dropdown",
				previewer = false,
			},
			buffers = {
				theme = "dropdown",
				previewer = false,
			},
		},
	})
end

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	lazy = false,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = config,
	keys = {
		mapkey("<leader>fk", "Telescope keymaps", "n"),
		mapkey("<leader>fh", "Telescope help_tags", "n"),
		mapkey("<leader>ff", "Telescope find_files", "n"), --'Telescope find files
		mapkey("<leader>fg", "Telescope live_grep", "n"), --Telescope live grep
		mapkey("<leader>fb", "Telescope buffers", "n"),
    mapkey("<leader>fr", "Telescope git_branches", "n"),--Telescope find branch
	},
}
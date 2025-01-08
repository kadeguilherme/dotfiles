-----------------------------------------------------------
-- name : neo-tree.nvim
-- url  : https://github.com/nvim-neo-tree/neo-tree.nvim
-----------------------------------------------------------

return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			source_selector = {
				winbar = true,
				sources = {
					{
						source = "filesystem",
						display_name = " 󰉓 Files ",
					},
					{
						source = "buffers",
						display_name = " 󰈚 Buffers ",
					},
					{
						source = "git_status",
						display_name = " 󰊢 Git ",
					},
				},
			},
			default_component_configs = {
				git_status = {
					symbols = {
						unstaged = "✚",
						staged = "✔",
						untracked = "★",
						deleted = "✘",
						ignored = "☒",
					},
				},
			},
		})
		-- Mapeamentos de teclas
		vim.keymap.set(
			"n",
			"<leader>/",
			":Neotree toggle current reveal_force_cwd<CR>",
			{ noremap = true, silent = true }
		)
		vim.keymap.set("n", "<leader>e", ":Neotree focus filesystem<CR>", { desc = "Open Neo-tree Filesystem" })
		vim.keymap.set("n", "<leader>b", ":Neotree focus buffers<CR>", { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>s", ":Neotree float git_status<CR>", { noremap = true, silent = true })
	end,
}

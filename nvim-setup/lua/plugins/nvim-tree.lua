-------------------------------------------------
-- name : neo-tree.nvim
-- url  : https://github.com/nvim-neo-tree/neo-tree.nvim
----------------------------------------------

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		-- Define icons for diagnostic signs
		vim.fn.sign_define("DiagnosticSignError", { text = "✖", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "⚠", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticSignHint" })

		-- Setup Neo-tree
		require("neo-tree").setup({
			close_if_last_window = true,
			enable_git_status = true,
			enable_diagnostics = true,
			sort_case_insensitive = false,

			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				diagnostics = {
					symbols = {
						error = "✖",
						warn = "⚠",
						info = "",
						hint = "💡",
					},
				},
				git_status = {
					symbols = {
						added = "", -- Arquivo adicionado
						modified = "", -- Arquivo modificado
						deleted = "✖", -- Arquivo deletado
						renamed = "󰁕", -- Arquivo renomeado
						ignored = "", -- Arquivo ignorado
						unstaged = "󰄱", -- Mudanças não preparadas
						staged = "", -- Mudanças preparadas
						conflict = "", -- Conflito de merge
					},
				},
			},

			filesystem = {
				follow_current_file = {
					enabled = true, -- Não encontrar e focar o arquivo atual no buffer ativo
				},
				leave_dirs_open = false, -- Fechar automaticamente diretórios expandidos
			},

			git_status = {
				window = {
					position = "float",
					mappings = {
						["A"] = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},

			fuzzy_finder_mappings = { -- Define keymaps para filtro no modo fuzzy_finder
				["<down>"] = "move_cursor_down",
				["<C-n>"] = "move_cursor_down",
				["<up>"] = "move_cursor_up",
				["<C-p>"] = "move_cursor_up",
			},
		})
	end,
}

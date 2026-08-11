-- mini.indentscope
-- https://github.com/echasnovski/mini.indentscope
-- Vertical indent guide highlighting the current indentation level.
return {
	"echasnovski/mini.indentscope",
	version = false,
	event = "BufReadPost",
	opts = {
		options = { try_as_border = true },
	},
	config = function(_, opts)
		local mini = require("mini.indentscope")
		mini.setup(opts)

		-- cor da coluna vinda do grupo "Function" do tema ativo (segue qualquer colorscheme)
		local function set_hl()
			local func = vim.api.nvim_get_hl(0, { name = "Function", link = false })
			local color = func.fg or "#82aaff"
			vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = color })
		end
		set_hl()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

		-- desativa em telas auxiliares
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "help", "lazy", "mason", "checkhealth", "TelescopePrompt", "yazi" },
			callback = function()
				vim.b.miniindentscope_disable = true
			end,
		})
	end,
}

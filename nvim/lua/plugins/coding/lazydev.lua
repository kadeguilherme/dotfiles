-- lazydev.nvim
-- https://github.com/folke/lazydev.nvim
-- Completion and hover for plugin APIs in Lua: feeds lua_ls the lazy.nvim paths on demand.
return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			-- tipos do vim.uv (libuv), usados em config/filetypes.lua e config/lazy.lua
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}

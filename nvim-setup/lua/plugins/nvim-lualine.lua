-------------------------------------------------
-- name : nvim-lualine/lualine.nvim
-- url  : https://github.com/nvim-lualine/lualine.nvim
-----------------------------------------------

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup({
            options = {
                theme = 'auto',
                disabled_filetypes = {
                    statusline = { 'neo-tree', 'alpha' },
                    winbar = { 'neo-tree', 'alpha'},
                },
                always_divide_middle = true,
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
              },
        })
    end
}


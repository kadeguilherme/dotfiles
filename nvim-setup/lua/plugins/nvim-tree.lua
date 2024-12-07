-------------------------------------------------
-- name : nvim-tree
-- url  : https://github.com/nvim-tree/nvim-tree.lua
-------------------------------------------------
return{
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    
    config = {
        filters = {
            dotfiles = true,
        },
        
    }
}

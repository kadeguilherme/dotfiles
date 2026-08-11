-- cord.nvim
-- https://github.com/vyfor/cord.nvim
-- Discord Rich Presence integration for Neovim.
return {
  "vyfor/cord.nvim",
  event = "VeryLazy",
  opts = {
    editor = {
      client = "neovim",
      tooltip = "Building things with Neovim",
    },

    display = {
      swap_fields = true,
    },

    timestamp = {
      enabled = true,
      reset_on_change = false,
    },

    text = {
      viewing = function()
        return "💻 Coding in Neovim"
      end,

      workspace = function()
        return "💻 Coding in Neovim"
      end,

      editing = function()
        return ""
      end,

      file = function()
        return ""
      end,
    },

    assets = {
      lazy = {
        icon = "https://raw.githubusercontent.com/folke/lazy.nvim/main/.github/logo.svg",
        name = "lazy.nvim",
        tooltip = "The lazy plugin manager",
      },
    },
  },
}

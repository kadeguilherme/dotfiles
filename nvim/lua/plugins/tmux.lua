-- vim-tmux-navigator
-- https://github.com/christoomey/vim-tmux-navigator
-- Navigate between Vim and tmux panes with the same keybindings.
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "tmux: pane à esquerda" },
    { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "tmux: pane abaixo" },
    { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "tmux: pane acima" },
    { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "tmux: pane à direita" },
    { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "tmux: pane anterior" },
  },
}

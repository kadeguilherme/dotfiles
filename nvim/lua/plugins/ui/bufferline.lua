-- bufferline.nvim
-- https://github.com/akinsho/bufferline.nvim
-- Buffer tabs in the tabline, showing paths, icons and LSP diagnostics.
local rotulos, sujo = {}, true

---@param rel string
---@return string
local function compactar(rel)
  local LIMITE = 34
  if vim.fn.strdisplaywidth(rel) <= LIMITE then
    return rel
  end
  local p = vim.split(rel, "/", { plain = true, trimempty = true })
  if #p <= 3 then
    return rel
  end
  return table.concat({ p[1], "…", p[#p - 1], p[#p] }, "/")
end

local function recalcular()
  local paths = require("util.paths")
  local mapa = paths.unique_suffixes(paths.listed_buffer_names(), 2)
  rotulos = {}
  for abs, rel in pairs(mapa) do
    rotulos[abs] = compactar(rel)
  end
  sujo = false
end

return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "L", "<cmd>BufferLineCycleNext<cr>", desc = "Próximo buffer" },
    { "H", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior" },
    { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pular para buffer (letra)" },
    { "<leader>bP", "<cmd>BufferLineTogglePin<cr>", desc = "Fixar/soltar buffer" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Fechar os outros buffers" },
    { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Fechar buffers à esquerda" },
    { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Fechar buffers à direita" },
    { "<leader>b<", "<cmd>BufferLineMovePrev<cr>", desc = "Mover buffer para a esquerda" },
    { "<leader>b>", "<cmd>BufferLineMoveNext<cr>", desc = "Mover buffer para a direita" },
  },
  opts = {
    options = {
      mode = "buffers",
      sort_by = "insert_after_current",
      themable = true,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(_, _, diag)
        local partes = {}
        if diag.error then
          table.insert(partes, " " .. diag.error)
        end
        if diag.warning then
          table.insert(partes, " " .. diag.warning)
        end
        return table.concat(partes, " ")
      end,

      -- "pasta/arquivo", crescendo só quando dois buffers abertos gerariam o
      -- mesmo texto. Mesma função usada pelo <leader>bb e pelo Telescope.
      --
      -- Quando o rótulo fica longo, encurtamos AQUI em vez de deixar o
      -- bufferline truncar: ele corta pela direita e comia justamente o final
      -- ("shard-pqtu/customers/apim-internal/eks/…"), que é o nome do arquivo.
      -- A elisão abaixo preserva o primeiro componente (o que desambigua) e os
      -- dois últimos (pasta imediata + arquivo).
      name_formatter = function(buf)
        if not buf.path or buf.path == "" then
          return buf.name
        end
        if sujo then
          recalcular()
        end
        local abs = vim.fn.fnamemodify(buf.path, ":p")
        return rotulos[abs] or compactar(vim.fn.fnamemodify(buf.path, ":t"))
      end,

      -- Precisa acomodar o rótulo já encurtado acima sem cortar de novo.
      max_name_length = 36,
      tab_size = 20,
      truncate_names = true,

      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = "thin",
      always_show_bufferline = false, -- com um buffer só (ex: dashboard) a barra some
      offsets = {},

      -- Clique do meio fecha; clique esquerdo vai para o buffer.
      middle_mouse_command = "bdelete! %d",

      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufFilePost" }, {
      group = vim.api.nvim_create_augroup("user_bufferline_rotulos", { clear = true }),
      callback = function()
        sujo = true
      end,
    })
  end,
}

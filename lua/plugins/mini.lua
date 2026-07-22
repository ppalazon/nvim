-- Mini plugins
vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.nvim" }
})

-- Activate mini.comments
require("mini.comment").setup()

-- lua/plugins/theme.lua
--
-- ================
-- Tokyonight Theme
-- ================
-- vim.pack.add({
--   "https://github.com/folke/tokyonight.nvim"
-- })
--
-- require("tokyonight").setup({
--   style = "night",
--   transparent = true,
-- })
--
-- vim.cmd("colorscheme tokyonight")

-- ===========
-- Ember theme
-- ===========
-- vim.pack.add({
--   "https://github.com/ember-theme/nvim"
-- })
--
-- require("ember").setup({
--   variant = "ember",
-- })
--
-- vim.cmd("colorscheme ember")

-- ===========
-- Catppuccin
-- ===========
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
  flavour = "mocha",
})

vim.cmd("colorscheme catppuccin-nvim")

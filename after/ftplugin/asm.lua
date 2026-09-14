vim.bo.commentstring = "/* %s */"
vim.bo.comments = "s1:/*,mb:*,ex:*/,://,:#,:;"

vim.bo.expandtab = true
vim.bo.tabstop = 8
vim.bo.softtabstop = 2
vim.bo.shiftwidth = 2

vim.bo.formatoptions = "jcroql"
vim.bo.textwidth = 0

vim.b.undo_ftplugin = table.concat({
  "setlocal commentstring< comments<",
  "setlocal expandtab< tabstop< softtabstop< shiftwidth<",
  "setlocal formatoptions< textwidth<",
}, " | ")

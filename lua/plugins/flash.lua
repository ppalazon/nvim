-- You can read more about this configuration on https://tduyng.com/blog/neovim-enhance-editing-experiences/
vim.pack.add({
  "https://github.com/folke/flash.nvim",
})

local flash = require("flash")
flash.setup({
  modes = {
    -- Enhanced f, t, F, T motions
    char = {
      enabled = true,
      jump_labels = true,
    },
  },
})

vim.keymap.set("x", ";", function()
  require("vim.treesitter._select").select_parent(vim.v.count1)
end, { desc = "Expand Syntax Selection" })
vim.keymap.set("x", ",", function()
  require("vim.treesitter._select").select_child(vim.v.count1)
end, { desc = "Shrink Syntax Selection" })

-- Keymaps
-- stylua: ignore start
-- At `s` there's mini.surrounding configured
vim.keymap.set({ "n", "x", "o" }, "ss", function() flash.jump() end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function() flash.treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function() flash.remote() end, { desc = "Remote Flash" })
vim.keymap.set({ "x", "o" }, "R", function() flash.treesitter_search() end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function() flash.toggle() end, { desc = "Toggle Flash Search" })
-- stylua: ignore end

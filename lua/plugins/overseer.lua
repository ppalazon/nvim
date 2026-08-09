vim.pack.add({
  "https://github.com/stevearc/overseer.nvim",
})

require("overseer").setup()

vim.keymap.set("n", "<F5>", "<cmd>OverseerRun<cr>", { desc = "Run Project Task" })

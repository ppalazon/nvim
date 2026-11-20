vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/pwntester/octo.nvim",
})

require("octo").setup({
  picker = "snacks",
  mappings = {
    pull_request = {
      review = { lhs = "<leader>grr", desc = "Start or resume GitHub review" },
    },
    review_diff = {
      add_review_comment = {
        lhs = "<leader>gra",
        desc = "Add GitHub review comment",
        mode = { "n", "x" },
      },
      review_commits = { lhs = "<leader>grc", desc = "Choose PR commit to review" },
      submit_review = { lhs = "<leader>grs", desc = "Submit GitHub review" },
    },
    file_panel = {
      review_commits = { lhs = "<leader>grc", desc = "Choose PR commit to review" },
      submit_review = { lhs = "<leader>grs", desc = "Submit GitHub review" },
    },
  },
})

vim.keymap.set("n", "<leader>grl", "<Cmd>Octo pr list<CR>", { desc = "List GitHub pull requests" })

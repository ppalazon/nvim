vim.pack.add({
  "https://github.com/stevearc/overseer.nvim",
})

require("overseer").setup({
  task_win = {
    padding = 4,
    border = "rounded",
  },
  component_aliases = {
    default = {
      "on_exit_set_status",
      "on_complete_notify",
      { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
      {
        "open_output",
        direction = "float",
        focus = true,
        on_start = "always",
      },
    },
  },
})

vim.keymap.set("n", "<F5>", "<cmd>OverseerRun<cr>", { desc = "Run Project Task" })

vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<cr>", { desc = "Run Project Task" })
vim.keymap.set("n", "<leader>os", "<cmd>OverseerShell<cr>", { desc = "Run Shell Command" })
vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle bottom<cr>", { desc = "Toggle Task List" })
vim.keymap.set("n", "<leader>oa", "<cmd>OverseerTaskAction<cr>", { desc = "Task Action" })
vim.keymap.set("n", "<leader>oq", "<cmd>OverseerClose<cr>", { desc = "Close Task List" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "OverseerOutput",
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      desc = "Close Task Output",
    })
  end,
})

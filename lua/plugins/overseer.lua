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
      "follow_output",
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

-- Overseer lists templates in provider order (the just provider is unordered).
-- Sort the OverseerRun launcher alphabetically.
-- snacks.nvim replaces vim.ui.select on UIEnter, so wrap it after that.
local function sort_overseer_templates()
  local ui_select = vim.ui.select
  vim.ui.select = function(items, opts, on_choice)
    if opts and opts.kind == "overseer_template" then
      items = vim.list_slice(items)
      table.sort(items, function(a, b)
        return a.name:lower() < b.name:lower()
      end)
    end
    return ui_select(items, opts, on_choice)
  end
end

if vim.v.vim_did_enter == 1 then
  sort_overseer_templates()
else
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      vim.schedule(sort_overseer_templates)
    end,
  })
end

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

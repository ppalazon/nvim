-- Agent-agnostic code review: comments are exported as markdown to the
-- clipboard, so they can be pasted into any coding agent.
vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/esmuellert/codediff.nvim",
  "https://github.com/georgeguimaraes/review.nvim",
  "https://github.com/eltonsst/postilla.nvim",
})

require("review").setup({})
require("postilla").setup({})

local map = vim.keymap.set

-- review.nvim: typed comments on diffs and notes on any file
map("n", "<leader>rr", "<Cmd>Review<CR>", { desc = "Review working tree" })
map("n", "<leader>rc", "<Cmd>Review commits<CR>", { desc = "Review commits" })
map("n", "<leader>rb", "<Cmd>Review branch<CR>", { desc = "Review branch" })
map({ "n", "x" }, "<leader>rn", ":Review note<CR>", { desc = "Review: note here", silent = true })
map("n", "<leader>re", "<Cmd>Review edit<CR>", { desc = "Review: edit comment" })
map("n", "<leader>rd", "<Cmd>Review delete<CR>", { desc = "Review: delete comment" })
map("n", "<leader>rl", "<Cmd>Review list<CR>", { desc = "Review: list comments" })
map("n", "<leader>rx", "<Cmd>Review export<CR>", { desc = "Review: copy comments" })

-- postilla.nvim: inline comments on regular buffers
local function with_comment_id(prompt, command)
  vim.ui.input({ prompt = prompt }, function(id)
    if id and id ~= "" then
      vim.cmd(command .. " " .. id)
    end
  end)
end

map("n", "<leader>as", "<Cmd>PostillaStart<CR>", { desc = "Postilla: start or restore review" })
map({ "n", "x" }, "<leader>ac", ":PostillaComment<CR>", { desc = "Postilla: comment", silent = true })
map("n", "<leader>ae", function()
  with_comment_id("Edit comment (ex. R1): ", "PostillaEdit")
end, { desc = "Postilla: edit comment" })
map("n", "<leader>ad", function()
  with_comment_id("Delete comment (ex. R1): ", "PostillaDelete")
end, { desc = "Postilla: delete comment" })
map("n", "<leader>al", "<Cmd>PostillaList<CR>", { desc = "Postilla: list comments" })
map("n", "<leader>ap", "<Cmd>PostillaPreview<CR>", { desc = "Postilla: preview feedback" })
map("n", "<leader>ax", "<Cmd>PostillaExport<CR>", { desc = "Postilla: copy without finishing" })
map("n", "<leader>aD", "<Cmd>PostillaDone<CR>", { desc = "Postilla: copy and finish" })
map("n", "<leader>aa", "<Cmd>PostillaAbort<CR>", { desc = "Postilla: discard review" })
map("n", "]r", "<Cmd>PostillaNext<CR>", { desc = "Next Postilla comment" })
map("n", "[r", "<Cmd>PostillaPrev<CR>", { desc = "Previous Postilla comment" })

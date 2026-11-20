-- You can read more about this configuration on https://tduyng.com/blog/neovim-git-tools/
vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/esmuellert/codediff.nvim",
  "https://github.com/afonsofrancof/worktrees.nvim",
})

require("worktrees").setup({
  mappings = { switch = "<leader>gw" },
})

-- Setup gitsigns.nvim
require("gitsigns").setup({
  current_line_blame = true,
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
    end

    map("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next Hunk")

    map("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev Hunk")

    map("n", "]H", function()
      gs.nav_hunk("last")
    end, "Last Hunk")
    map("n", "[H", function()
      gs.nav_hunk("first")
    end, "First Hunk")

    map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")

    map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
    map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame Line")
    map("n", "<leader>ghB", function()
      gs.blame()
    end, "Blame Buffer")
    map("n", "<leader>ghd", gs.diffthis, "Diff This")
    map("n", "<leader>ghD", function()
      gs.diffthis("~")
    end, "Diff This ~")

    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  end,
})

require("codediff").setup({
  diff = {
    layout = "inline",
  },
  explorer = {
    width = 40,
  },
  history = {
    height = 15,
  },
})

vim.keymap.set("n", "<leader>gd", "<Cmd>CodeDiff<CR>", { desc = "Diff: git status" })
vim.keymap.set("n", "<leader>gv", "<Cmd>CodeDiff history<CR>", { desc = "Diff: repo history" })
vim.keymap.set("n", "<leader>gV", "<Cmd>CodeDiff history %<CR>", { desc = "Diff: current file history" })
vim.keymap.set("v", "<leader>gv", ":'<,'>CodeDiff history<CR>", { desc = "Diff: selection history" })

-- Compare with revisions (prompts)
vim.keymap.set("n", "<leader>gc", function()
  vim.ui.input({ prompt = "Compare revision (ex. main, HEAD~5, main..HEAD): " }, function(refs)
    if refs and refs:match("%S") then
      vim.cmd(("CodeDiff %s"):format(refs))
    end
  end)
end, { desc = "Diff: compare revisions" })

vim.keymap.set("n", "<leader>gC", function()
  vim.ui.input({ prompt = "File history range (ex. HEAD~1, main..HEAD): " }, function(range)
    if range and range:match("%S") then
      vim.cmd(("CodeDiff history %s %%"):format(range))
    end
  end)
end, { desc = "Diff: file history with range" })

-- Compare two arbitrary files
vim.keymap.set("n", "<leader>g2", function()
  vim.ui.input({ prompt = "First file: " }, function(file1)
    if not file1 or not file1:match("%S") then
      return
    end
    vim.ui.input({ prompt = "Second file: " }, function(file2)
      if file2 and file2:match("%S") then
        vim.cmd(("CodeDiff file %s %s"):format(vim.fn.fnameescape(file1), vim.fn.fnameescape(file2)))
      end
    end)
  end)
end, { desc = "Diff: Compare 2 files" })

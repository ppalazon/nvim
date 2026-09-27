local M = {}

local prose_filetypes = { "gitcommit", "markdown", "plaintex", "text", "tex", "typst" }

local function set_spell(bufnr, enabled)
  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_set_option_value("spell", enabled, { win = winid })
  end
end

local function detach_harper(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "harper_ls" })) do
    vim.lsp.buf_detach_client(bufnr, client.id)
  end
end

local function start_harper(bufnr)
  local config = vim.deepcopy(vim.lsp.config.harper_ls)
  config.root_dir = vim.fs.root(bufnr, { ".harper-dictionary.txt", ".git" }) or vim.uv.cwd()
  config.root_markers = nil
  vim.lsp.start(config, { bufnr = bufnr })
end

local function toggle_harper()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "harper_ls" })

  if #clients > 0 then
    detach_harper(bufnr)
    vim.notify("Harper grammar: Disabled")
    return
  end

  if vim.b[bufnr].spell_language ~= "english" then
    vim.notify("Harper grammar requires English spelling", vim.log.levels.WARN)
    return
  end

  start_harper(bufnr)
  vim.notify("Harper grammar: Enabled")
end

function M.set(language, opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local enabled = language ~= "off"

  vim.b[bufnr].spell_language = language
  if enabled then
    vim.api.nvim_set_option_value("spelllang", language == "spanish" and "es" or "en", { buf = bufnr })
  end
  set_spell(bufnr, enabled)

  if language ~= "english" then
    detach_harper(bufnr)
  end

  if opts.notify ~= false then
    local label = language:sub(1, 1):upper() .. language:sub(2)
    vim.notify("Spelling: " .. label)
  end
end

vim.api.nvim_create_user_command("SpellEnglish", function()
  M.set("english")
end, { desc = "Use English spelling in this buffer" })

vim.api.nvim_create_user_command("SpellSpanish", function()
  M.set("spanish")
end, { desc = "Use Spanish spelling in this buffer" })

vim.api.nvim_create_user_command("SpellOff", function()
  M.set("off")
end, { desc = "Disable spelling and Harper in this buffer" })

vim.api.nvim_create_user_command("HarperToggle", toggle_harper, {
  desc = "Toggle Harper grammar checking in this buffer",
})

vim.keymap.set("n", "<leader>use", "<cmd>SpellEnglish<cr>", { desc = "Spelling: English" })
vim.keymap.set("n", "<leader>uss", "<cmd>SpellSpanish<cr>", { desc = "Spelling: Spanish" })
vim.keymap.set("n", "<leader>uso", "<cmd>SpellOff<cr>", { desc = "Spelling: Off" })
vim.keymap.set("n", "<leader>ush", "<cmd>HarperToggle<cr>", { desc = "Harper grammar" })

local spell_group = vim.api.nvim_create_augroup("user_spell_language", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = spell_group,
  pattern = prose_filetypes,
  callback = function(event)
    M.set("english", { bufnr = event.buf, notify = false })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = spell_group,
  callback = function(event)
    local language = vim.b[event.buf].spell_language
    if language then
      vim.opt_local.spell = language ~= "off"
    end
  end,
})

return M

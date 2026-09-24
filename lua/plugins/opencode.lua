vim.pack.add({
  {
    src = "https://github.com/nickjvandyke/opencode.nvim",
    version = vim.version.range("^1"),
  },
})

local opencode_cmd = "opencode --port"
local opencode_terminal

local function terminal_opts()
  return {
    cwd = vim.fn.getcwd(),
    win = { position = "bottom", height = 0.4, enter = false, fixbuf = true },
  }
end

local function open_terminal()
  if not (opencode_terminal and opencode_terminal:buf_valid()) then
    opencode_terminal = require("snacks.terminal").get(opencode_cmd, terminal_opts())
  end

  opencode_terminal:show()
end

local function close_terminal()
  if not (opencode_terminal and opencode_terminal:buf_valid()) then
    opencode_terminal =
      require("snacks.terminal").get(opencode_cmd, vim.tbl_extend("force", terminal_opts(), { create = false }))
  end

  if opencode_terminal then
    opencode_terminal:hide()
  end
end

local function toggle_terminal()
  if not (opencode_terminal and opencode_terminal:buf_valid()) then
    opencode_terminal = require("snacks.terminal").get(opencode_cmd, terminal_opts())
    return
  end

  opencode_terminal:toggle()
end

local function current_file_is_modified()
  local path = vim.api.nvim_buf_get_name(0)
  return path ~= "" and vim.bo.modified and vim.uv.fs_stat(path) ~= nil
end

local function ask(default)
  if current_file_is_modified() then
    vim.notify("Save the current buffer before sending @this to OpenCode", vim.log.levels.WARN, { title = "OpenCode" })
    return
  end

  require("opencode").ask(default)
end

local function select_session()
  require("opencode.server.discovery")
    .get()
    :next(function(server)
      return require("opencode.ui.select_session").select_session(server):next(function(session)
        return server:select_session(session.id)
      end)
    end)
    :catch(function(err)
      if err then
        vim.notify(err, vim.log.levels.ERROR, { title = "OpenCode" })
      end
    end)
end

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    start = open_terminal,
  },
  ask = {
    snacks = {
      expand = false,
      win = {
        relative = "editor",
        row = 2,
        col = 0.1,
        width = 0.8,
        height = 8,
        wo = {
          wrap = true,
          linebreak = true,
          breakindent = true,
        },
      },
    },
  },
}

local active_sessions = {}
local request_failed = false

local function notify_desktop(urgency, summary, body)
  if vim.fn.executable("notify-send") == 0 then
    return
  end

  vim.system({
    "notify-send",
    "--app-name=OpenCode",
    "--urgency=" .. urgency,
    summary,
    body,
  })
end

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("OpencodeDesktopNotifications", { clear = true }),
  pattern = { "OpencodeEvent:session.status", "OpencodeEvent:permission.asked" },
  callback = function(args)
    local event = args.data.event
    local properties = event.properties or {}

    if event.type == "permission.asked" then
      notify_desktop("critical", "OpenCode needs permission", properties.permission or "Permission requested")
      return
    end

    local status = properties.status and properties.status.type
    local session_id = properties.sessionID or args.data.url
    if status == "busy" then
      if next(active_sessions) == nil then
        request_failed = false
      end
      active_sessions[session_id] = true
      return
    end

    if not active_sessions[session_id] or (status ~= "idle" and status ~= "error") then
      return
    end

    active_sessions[session_id] = nil
    request_failed = request_failed or status == "error"
    if next(active_sessions) == nil then
      notify_desktop(
        request_failed and "critical" or "normal",
        "OpenCode",
        request_failed and "Request failed" or "Request finished"
      )
    end
  end,
  desc = "Send OpenCode desktop notifications",
})

vim.keymap.set("n", "<leader>ai", function()
  ask(
    "Edit the current file at @this. Insert code or text suitable for this exact cursor position. "
      .. "Inspect the surrounding code, preserve its style, and avoid explanations unless needed. Task: "
  )
end, { desc = "AI insert at cursor" })

vim.keymap.set("x", "<leader>ai", function()
  ask("Rewrite @this in place. Preserve indentation and the surrounding style, and use the edit review flow. Task: ")
end, { desc = "AI replace selection" })

vim.keymap.set({ "n", "x" }, "<leader>aa", function()
  ask("Ask about @this: ")
end, { desc = "Ask OpenCode about code" })

vim.keymap.set("n", "<leader>ae", function()
  require("opencode").ask(
    "Work on the current project. Inspect and edit any relevant files, update callers, and run appropriate checks. Task: "
  )
end, { desc = "OpenCode project task" })

vim.keymap.set("n", "<leader>as", select_session, { desc = "Select OpenCode session" })
vim.keymap.set("n", "<leader>ao", open_terminal, { desc = "Open OpenCode terminal" })
vim.keymap.set("n", "<leader>ac", close_terminal, { desc = "Close OpenCode terminal" })
vim.keymap.set({ "n", "t" }, "<F3>", toggle_terminal, { desc = "Toggle OpenCode terminal" })

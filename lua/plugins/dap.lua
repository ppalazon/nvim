vim.pack.add({
  "https://codeberg.org/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rcarriga/nvim-dap-ui",
})

local dap = require("dap")
local dapui = require("dapui")

local function mason_executable(name)
  local executable = vim.fn.exepath(name)
  if executable ~= "" then
    return executable
  end

  return vim.fn.stdpath("data") .. "/mason/bin/" .. name
end

dap.adapters.codelldb = function(callback)
  callback({
    type = "server",
    port = "${port}",
    executable = {
      command = mason_executable("codelldb"),
      args = { "--port", "${port}" },
    },
  })
end

dap.adapters.python = function(callback, config)
  if config.request == "attach" then
    local connection = config.connect or config
    callback({
      type = "server",
      host = connection.host or "127.0.0.1",
      port = assert(connection.port, "`connect.port` is required for a Python attach configuration"),
      options = { source_filetype = "python" },
    })
    return
  end

  callback({
    type = "executable",
    command = mason_executable("debugpy-adapter"),
    options = { source_filetype = "python" },
  })
end

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- stylua: ignore start
map("n", "<leader>dc", dap.continue, "Debug Continue")
map("n", "<leader>db", dap.toggle_breakpoint, "Debug Toggle Breakpoint")
map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Debug Conditional Breakpoint")
map("n", "<leader>dC", dap.run_to_cursor, "Debug Run to Cursor")
map("n", "<leader>di", dap.step_into, "Debug Step Into")
map("n", "<leader>dj", dap.down, "Debug Stack Frame Down")
map("n", "<leader>dk", dap.up, "Debug Stack Frame Up")
map("n", "<leader>do", dap.step_over, "Debug Step Over")
map("n", "<leader>dO", dap.step_out, "Debug Step Out")
map("n", "<leader>dl", dap.run_last, "Debug Run Last")
map("n", "<leader>dL", function() dap.list_breakpoints(true) end, "Debug List Breakpoints")
map("n", "<leader>dP", dap.pause, "Debug Pause")
map("n", "<leader>dr", dap.repl.toggle, "Debug Toggle REPL")
map("n", "<leader>dt", dap.terminate, "Debug Terminate")
map("n", "<leader>du", dapui.toggle, "Debug Toggle UI")
map({ "n", "x" }, "<leader>de", dapui.eval, "Debug Evaluate")
map("x", "<leader>dw", function() dapui.elements.watches.add() end, "Debug Watch Selection")
map("n", "<leader>dx", dap.clear_breakpoints, "Debug Clear Breakpoints")

-- F5 is for overseer plugin to start applications
map("n", "<F6>", dap.continue, "Debug Continue")
-- map("n", "<S-F6>", dap.pause, "Debug Pause")
map("n", "<F8>", dap.toggle_breakpoint, "Debug Toggle Breakpoint")
map("n", "<F9>", dap.step_over, "Debug Step Over")
map("n", "<F10>", dap.step_into, "Debug Step Into")
map("n", "<F11>", dap.step_out, "Debug Step Out")
-- map("n", "<F7>", dap.terminate, "Debug Terminate")
-- stylua: ignore end

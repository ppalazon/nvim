local dap = require("dap")
local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()

local function python_path()
  local virtualenv = root .. "/.venv/bin/python"
  if vim.fn.executable(virtualenv) == 1 then
    return virtualenv
  end

  return vim.fn.exepath("python3")
end

dap.configurations.python = {
  {
    name = "Launch application",
    type = "python",
    request = "launch",
    program = root .. "/src/main.py",
    cwd = root,
    pythonPath = python_path,
    args = {},
    console = "integratedTerminal",
  },
}

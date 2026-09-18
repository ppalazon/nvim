local dap = require("dap")
local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()

dap.configurations.c = {
  {
    name = "Launch application",
    type = "codelldb",
    request = "launch",
    program = root .. "/build/app",
    cwd = root,
    args = {},
    stopOnEntry = false,
  },
}

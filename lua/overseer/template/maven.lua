local function project_root(dir)
  local wrapper = vim.fs.find("mvnw", { upward = true, type = "file", path = dir })[1]
  if wrapper then
    return vim.fs.dirname(wrapper), wrapper
  end

  local pom = vim.fs.find("pom.xml", { upward = true, type = "file", path = dir })[1]
  if pom then
    return vim.fs.dirname(pom)
  end
end

return {
  generator = function(opts)
    local root, wrapper = project_root(opts.dir)
    if not root then
      return "No Maven project found"
    end

    local command = wrapper and vim.fn.executable(wrapper) == 1 and wrapper or "mvn"
    if vim.fn.executable(command) == 0 then
      return string.format("Could not find command '%s'", command)
    end

    local tasks = {}
    for _, goal in ipairs({ "compile", "test", "package", "verify" }) do
      table.insert(tasks, {
        name = "Maven " .. goal,
        builder = function()
          return { cmd = { command, goal }, cwd = root, components = { "default" } }
        end,
      })
    end
    return tasks
  end,
}

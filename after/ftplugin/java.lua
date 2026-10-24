local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local file_name = vim.api.nvim_buf_get_name(0)
local search_dir = file_name == "" and vim.fn.getcwd() or vim.fs.dirname(file_name)
local pom = vim.fs.find("pom.xml", { upward = true, type = "file", path = search_dir })[1]
if not pom then
  return
end

local root_dir = vim.fs.dirname(pom)
local wrapper = vim.fs.find("mvnw", { upward = true, type = "file", path = root_dir })[1]
if wrapper then
  root_dir = vim.fs.dirname(wrapper)
end

local mason_packages = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages")
local bundles = vim.fn.glob(
  vim.fs.joinpath(mason_packages, "java-debug-adapter", "extension", "server", "com.microsoft.java.debug.plugin-*.jar"),
  true,
  true
)

for _, bundle in
  ipairs(vim.fn.glob(vim.fs.joinpath(mason_packages, "java-test", "extension", "server", "*.jar"), true, true))
do
  local name = vim.fs.basename(bundle)
  if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
    table.insert(bundles, bundle)
  end
end

local runtimes = {}
for _, version in ipairs({ "8", "11", "17", "21", "27" }) do
  local path = "/usr/lib/jvm/java-" .. version .. "-openjdk"
  if vim.uv.fs_stat(path) then
    table.insert(runtimes, { name = version == "8" and "JavaSE-1.8" or "JavaSE-" .. version, path = path })
  end
end

local formatter_settings
for _, relative_path in ipairs({
  ".eclipse-formatter.xml",
  "eclipse-formatter.xml",
  ".settings/eclipse-formatter.xml",
  "config/eclipse-formatter.xml",
}) do
  local path = vim.fs.joinpath(root_dir, relative_path)
  if vim.uv.fs_stat(path) then
    formatter_settings = path
    break
  end
end

local settings = {
  java = {
    configuration = { runtimes = runtimes },
  },
}
if formatter_settings then
  settings.java.format = {
    settings = { url = formatter_settings },
  }
end

local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "jdtls", vim.fn.sha256(root_dir))

jdtls.start_or_attach({
  cmd = { vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "jdtls"), "-data", workspace_dir },
  root_dir = root_dir,
  init_options = { bundles = bundles },
  settings = settings,
}, { dap = {} })

vim.keymap.set("n", "<leader>df", jdtls.test_class, { buffer = true, desc = "Debug Java Test Class" })
vim.keymap.set("n", "<leader>dn", jdtls.test_nearest_method, { buffer = true, desc = "Debug Nearest Java Test" })

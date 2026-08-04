local M = {}

local block_nodes = {
  block_quote = true,
  fenced_code_block = true,
  indented_code_block = true,
  list_item = true,
  paragraph = true,
}

local skip_nodes = {
  fenced_code_block = true,
  indented_code_block = true,
}

local function get_prefix(line)
  local leading = line:match("^[ \t]*") or ""
  local rest = line:sub(#leading + 1)
  local marker = rest:match("^[>+*%-][ \t]+") or rest:match("^%d+[%.%)][ \t]+") or ""

  return leading .. marker
end

local function strip_prefix(line)
  local rest = line:gsub("^[ \t]*", "")
  rest = rest:gsub("^[>+*%-][ \t]+", "")
  rest = rest:gsub("^%d+[%.%)][ \t]+", "")

  return rest
end

local function wrap_words(words, prefix, cont, width)
  local out = {}
  local line = ""

  for _, word in ipairs(words) do
    if line == "" then
      line = word
    elseif #line + 1 + #word <= width then
      line = line .. " " .. word
    else
      out[#out + 1] = line
      line = word
    end
  end

  if line ~= "" then
    out[#out + 1] = line
  end

  for i, l in ipairs(out) do
    out[i] = (i == 1 and prefix or cont) .. l
  end

  return out
end

local function node_type_at(bufnr, row, col)
  local ok, node = pcall(vim.treesitter.get_node, {
    bufnr = bufnr,
    pos = { row, col },
    ignore_injections = true,
  })
  if not ok or not node then
    return nil
  end

  while node and not block_nodes[node:type()] do
    node = node:parent()
  end

  return node and node:type() or nil
end

function M.formatexpr()
  -- Only handle explicit formatting (gq/gw), not insert-mode auto-wrap.
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 1) == "i" or mode:sub(1, 1) == "R" then
    return 1
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local start_row = vim.v.lnum - 1
  local end_row = start_row + math.max(vim.v.count, 1) - 1

  for row = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
    local col = math.max((line:find("%S") or 1) - 1, 0)
    local node_type = node_type_at(bufnr, row, col)
    if skip_nodes[node_type] then
      return 0
    end
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

  -- Preserve semantic line breaks (two trailing spaces = hard <br>):
  -- leave such paragraphs untouched instead of reflowing them
  for _, l in ipairs(lines) do
    if l:find("%s%s$") then
      return 0
    end
  end

  local textwidth = vim.bo[bufnr].textwidth > 0 and vim.bo[bufnr].textwidth or 79
  local out = {}
  local segment = {}
  local segment_prefix

  local function flush_segment()
    if vim.tbl_isempty(segment) then
      return
    end

    local words = vim.split(table.concat(segment, " "), "%s+", { trimempty = true })
    if not vim.tbl_isempty(words) then
      local prefix = segment_prefix or ""
      -- Continuation indent: keep `>` markers, replace the rest with spaces.
      local cont = prefix:gsub("[^ >]", " ")
      local width = textwidth - #cont
      if width < 20 then
        width = math.max(textwidth, 20)
      end

      vim.list_extend(out, wrap_words(words, prefix, cont, width))
    end

    segment = {}
  end

  for _, line in ipairs(lines) do
    if line:match("^%s*$") then
      flush_segment()
      out[#out + 1] = line
      segment_prefix = nil
    else
      local prefix = get_prefix(line)
      if segment_prefix and prefix ~= segment_prefix then
        flush_segment()
      end

      segment_prefix = prefix
      segment[#segment + 1] = strip_prefix(line)
    end
  end
  flush_segment()

  if vim.tbl_isempty(out) then
    return 1
  end

  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, out)
  return 0
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_markdown_format", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.bo.textwidth = 79
    vim.bo.formatexpr = "v:lua.require('config.markdown').formatexpr()"
  end,
})

return M

local M = {}

local function wrap_words(words, indent, width)
  local out = {}
  local line = ""

  for _, word in ipairs(words) do
    if line == "" then
      line = word
    elseif #line + 1 + #word <= width then
      line = line .. " " .. word
    else
      out[#out + 1] = indent .. line
      line = word
    end
  end

  if line ~= "" then
    out[#out + 1] = indent .. line
  end

  return out
end

local function leading_width(line)
  return #(line:match("^[ \t]*") or "")
end

local function is_block_scalar_marker(line)
  local trimmed = line:gsub("%s+#.*$", ""):gsub("%s+$", "")
  local suffix = trimmed:match("[>|]([^>|]*)$")

  return suffix ~= nil and (suffix:match("^[+-]?[1-9]?$") ~= nil or suffix:match("^[1-9]?[+-]?$") ~= nil)
end

local function is_block_scalar_content(bufnr, row, indent_width)
  if indent_width == 0 then
    return false
  end

  for scan = row - 1, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, scan, scan + 1, false)[1] or ""
    if not line:match("^%s*$") then
      local scan_indent_width = leading_width(line)
      if scan_indent_width < indent_width then
        return is_block_scalar_marker(line)
      end
    end
  end

  return false
end

local function wrap_lines(lines, textwidth)
  local out = {}
  local segment = {}
  local segment_indent

  local function flush_segment()
    if vim.tbl_isempty(segment) then
      return
    end

    local words = vim.split(table.concat(segment, " "), "%s+", { trimempty = true })
    if not vim.tbl_isempty(words) then
      vim.list_extend(out, wrap_words(words, segment_indent or "", textwidth))
    end

    segment = {}
    segment_indent = nil
  end

  for _, line in ipairs(lines) do
    if line:match("^%s*$") then
      flush_segment()
      out[#out + 1] = line
    else
      local indent = line:match("^[ \t]*") or ""
      local text = line:sub(#indent + 1)

      if segment_indent and indent ~= segment_indent then
        flush_segment()
      end

      segment_indent = indent
      segment[#segment + 1] = text
    end
  end
  flush_segment()

  return out
end

local function find_block_scalar_range(bufnr, row)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local marker_row
  local marker_indent_width

  for scan = row, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, scan, scan + 1, false)[1] or ""
    if is_block_scalar_marker(line) then
      marker_row = scan
      marker_indent_width = leading_width(line)
      break
    end
  end

  if not marker_row then
    return nil
  end

  local start_row
  for scan = marker_row + 1, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, scan, scan + 1, false)[1] or ""
    if not line:match("^%s*$") then
      if leading_width(line) <= marker_indent_width then
        return nil
      end

      start_row = scan
      break
    end
  end

  if not start_row then
    return nil
  end

  local end_row = start_row
  for scan = start_row + 1, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, scan, scan + 1, false)[1] or ""
    if not line:match("^%s*$") and leading_width(line) <= marker_indent_width then
      break
    end

    end_row = scan
  end

  if row < marker_row or row > end_row then
    return nil
  end

  return start_row, end_row
end

function M.wrap_block_scalar()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local start_row, end_row = find_block_scalar_range(bufnr, row)

  if not start_row then
    vim.notify("No YAML block scalar found", vim.log.levels.INFO)
    return
  end

  local textwidth = vim.bo[bufnr].textwidth > 0 and vim.bo[bufnr].textwidth or 80
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  local out = wrap_lines(lines, textwidth)

  if not vim.tbl_isempty(out) then
    vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, out)
  end
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
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  local textwidth = vim.bo[bufnr].textwidth > 0 and vim.bo[bufnr].textwidth or 80
  local out = {}
  local segment = {}

  for index, line in ipairs(lines) do
    if line:match("^%s*$") then
      vim.list_extend(out, wrap_lines(segment, textwidth))
      segment = {}
      out[#out + 1] = line
    else
      local indent = line:match("^[ \t]*") or ""
      if not is_block_scalar_content(bufnr, start_row + index - 1, #indent) then
        vim.list_extend(out, wrap_lines(segment, textwidth))
        segment = {}
        out[#out + 1] = line
      else
        segment[#segment + 1] = line
      end
    end
  end
  vim.list_extend(out, wrap_lines(segment, textwidth))

  if vim.tbl_isempty(out) then
    return 1
  end

  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, out)
  return 0
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_yaml_format", { clear = true }),
  pattern = { "yaml" },
  callback = function()
    vim.bo.textwidth = 80
    vim.bo.formatexpr = "v:lua.require('config.yaml').formatexpr()"
    vim.keymap.set("n", "<leader>cw", M.wrap_block_scalar, {
      buffer = true,
      desc = "Wrap YAML Block Scalar",
    })
  end,
})

return M

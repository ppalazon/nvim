local M = {}

function M.setup()
  local function move_comment(direction)
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    local comment_start = line:find("//", 1, true)

    if not comment_start then
      vim.notify("No // comment on this line", vim.log.levels.WARN)
      return
    end

    local comment = line:sub(comment_start)
    local code = line:sub(1, comment_start - 1):gsub("%s+$", "")
    local target_row = direction == "up" and row - 1 or row + 1
    if target_row < 0 or target_row >= vim.api.nvim_buf_line_count(0) then
      vim.notify("No adjacent line for this comment", vim.log.levels.WARN)
      return
    end

    local target = vim.api.nvim_buf_get_lines(0, target_row, target_row + 1, false)[1]
    local target_is_code = not target:match("^%s*$") and not target:match("^%s*//")

    if target_is_code then
      local attached = target:gsub("%s+$", "") .. " " .. comment
      if direction == "up" then
        local replacement = code == "" and { attached } or { attached, code }
        vim.api.nvim_buf_set_lines(0, target_row, row + 1, false, replacement)
        vim.api.nvim_win_set_cursor(0, { target_row + 1, 0 })
      else
        local replacement = code == "" and { attached } or { code, attached }
        vim.api.nvim_buf_set_lines(0, row, target_row + 1, false, replacement)
        vim.api.nvim_win_set_cursor(0, { row + (code == "" and 1 or 2), 0 })
      end
    else
      local indent = line:match("^(%s*)") or ""
      local comment_line = indent .. comment
      if direction == "up" then
        local replacement = { comment_line, target }
        if code ~= "" then
          table.insert(replacement, code)
        end
        vim.api.nvim_buf_set_lines(0, target_row, row + 1, false, replacement)
        vim.api.nvim_win_set_cursor(0, { target_row + 1, 0 })
      else
        local replacement = {}
        if code ~= "" then
          table.insert(replacement, code)
        end
        table.insert(replacement, target)
        table.insert(replacement, comment_line)
        vim.api.nvim_buf_set_lines(0, row, target_row + 1, false, replacement)
        vim.api.nvim_win_set_cursor(0, { row + #replacement, 0 })
      end
    end
  end

  vim.keymap.set("n", "<leader>ck", function()
    move_comment("up")
  end, { buffer = true, desc = "Move Comment Up" })

  vim.keymap.set("n", "<leader>cj", function()
    move_comment("down")
  end, { buffer = true, desc = "Move Comment Down" })
end

return M

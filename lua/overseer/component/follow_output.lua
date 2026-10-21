local util = require("overseer.util")

return {
  desc = "Keep task output scrolled to the latest line",
  constructor = function()
    local pending = false

    return {
      on_output = function(_, task)
        if pending then
          return
        end
        pending = true

        vim.defer_fn(function()
          pending = false
          local bufnr = task:get_bufnr()
          if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end

          for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
            if vim.api.nvim_win_is_valid(winid) then
              util.scroll_to_end(winid)
            end
          end
        end, 10)
      end,
    }
  end,
}

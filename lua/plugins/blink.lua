-- Configure blink as completation plugin
--
vim.pack.add({
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("^1"),
  },
})

-- Lazy load on first insert mode entry (may not necessary)
local group = vim.api.nvim_create_augroup("BlinkCmpLazyLoad", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  group = group,
  once = true,
  callback = function()
    require("blink.cmp").setup({
      keymap = {
        -- preset = "super-tab",
        preset = "default",
        -- ["<CR>"] = {
        --   function(cmp)
        --     if cmp.is_menu_visible() then
        --       return cmp.accept()
        --     end
        --
        --     return require("mini.pairs").cr()
        --   end,
        --   "fallback",
        -- },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
        use_nvim_cmp_as_default = true,
      },
      completion = {
        documentation = { auto_show = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            opts = {
              search_paths = {
                vim.fn.stdpath("config") .. "/lua/snippets",
              },
            },
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    })
  end,
})

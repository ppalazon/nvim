# Documentation

Before editing user-facing documentation, load the `technical-writing` and
`humanizer` skills. Verify each behavior, keymap, command, and path against the
current configuration. Code is the source of truth for paths and active
mappings.

Keep `README.md` focused on the configuration layout, plugins, grouped
keymaps, and repository-specific behavior such as debugging and tasks. The
`## Quick start` section is the keymap reference. Its sections are Files and
search, Buffers, Windows, Tabs, LSP (native), Git, Debug, Diagnostics,
Quickfix and location, Markdown, Sessions, `vim.pack`, UI toggles, and Tasks.

When a change under `init.lua`, `lua/`, `after/ftplugin/`, or `examples/dap/`
changes documented behavior, paths, plugins, keymaps, debugging, or tasks,
review and update the affected README content in the same task. For keymap
changes, verify the active mapping and its conditions, such as mode, filetype,
buffer-local scope, or lazy-load event, before updating `## Quick start`.

---
description: Audit active Neovim keymaps and synchronize README.md's grouped Quick start reference.
---

Delegate to the `keymap-docs` subagent to audit every active mapping in this
configuration. Update only `README.md`'s `## Quick start` section, using its
existing groups: Files and search, Buffers, Windows, Tabs, LSP (native), Git,
Debug, Diagnostics, Quickfix and location, Markdown, Sessions, `vim.pack`, UI
toggles, and Tasks.

Verify modes and conditional mappings, including filetype, buffer-local, LSP,
Git, picker, and lazy-load scopes. Keep non-keymap README content unchanged.
Review the result, verify changed entries against the Lua source, and run
`git diff --check`.

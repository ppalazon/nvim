---
description: Audit active Neovim keymaps and synchronize README.md's grouped Keymaps reference.
---

Delegate to the `keymap-docs` subagent to audit every active mapping in this
configuration. Update only the grouped mapping reference under `README.md`'s
`## Keymaps` heading. Preserve its existing groups and concise key-to-action
format.

Verify modes and conditional mappings, including filetype, buffer-local, LSP,
Git, picker, and lazy-load scopes. Include a scope only when needed to identify
when a mapping is active. Do not add prose about functionality, implementation,
setup, commands, paths, defaults, or workflows. Keep all content outside
`## Keymaps` unchanged. Review the result, verify changed entries against the
Lua source, and run `git diff --check`.

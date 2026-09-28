# Documentation

Before editing user-facing documentation, load the `technical-writing` and
`humanizer` skills. Verify each keymap against the current configuration. Code
is the source of truth for active mappings.

For documentation updates made alongside configuration changes, edit only the
grouped mapping reference under `README.md`'s `## Keymaps` heading. Use concise
key-to-action entries that match the existing lists. Include a mapping's mode,
filetype, or buffer-local scope only when needed to identify when it is active.

When a change under `init.lua`, `lua/`, `after/ftplugin/`, or `examples/dap/`
adds, removes, or changes a keymap, update the affected entry under `## Keymaps`
in the same task. Do not add prose about the feature, its implementation,
setup, commands, paths, defaults, or workflow unless the user explicitly asks
for that documentation.

# Neovim configuration

This configuration of neovim is based on Duy NG's one
(https://tduyng.com/series/neovim/).

This is my second try after considering kickstart
(https://github.com/nvim-lua/kickstart.nvim) and learning using neovim tutor.
It was at a complicated time because v0.12 was about to be released and many
posts and people talking about different versions at the same time. It was
difficult to learn with the latest resources because I couldn't tell apart how
to adapt new plugin to my old configuration.

I like this configuration because it's based on native built-in features and
only use plugins when it's necessary. I think it's easy to understand, and
there is no hidden configuration behind complicated plugins. In my opinion,
it's very simple to understand and very easy to get into neovim configuration.

I think you can learn more about this neovim configuration in the original repo
on [tduyng / nvim · GitLab](https://gitlab.com/tduyng/nvim)

## Plugins

| Plugin                                     | Purpose                                                     |
| ------------------------------------------ | ----------------------------------------------------------- |
| `blink.cmp`                                | Completion from LSP, snippets, paths, and buffer text.      |
| `catppuccin`                               | Mocha color scheme.                                         |
| `conform.nvim`                             | Format buffers and injected languages.                      |
| `flash.nvim`                               | Character and Treesitter jumps.                             |
| `gitsigns.nvim` and `diffview.nvim`        | Git signs, hunk actions, and diff views.                    |
| `grug-far.nvim`                            | Search and replace across files.                            |
| `nvim-lspconfig`, Mason, and Slang Server  | LSP servers, tools, and SystemVerilog support.              |
| `render-markdown.nvim` and `img-clip.nvim` | Markdown rendering and image pasting.                       |
| `mini.nvim`                                | Comment commands and automatic pairs.                       |
| `nvim-dap` and `nvim-dap-ui`               | Debugging for C and Python.                                 |
| `noice.nvim`                               | Command line, messages, and LSP documentation UI.           |
| `opencode.nvim`                            | OpenCode prompts, sessions, and native edit review.         |
| `overseer.nvim`                            | Project and shell tasks.                                    |
| `snacks.nvim`                              | Pickers, explorer, terminal, notifications, and UI toggles. |
| `nvim-treesitter`                          | Syntax parsing, text objects, and code navigation.          |
| `which-key.nvim`                           | Leader-key command groups and mapping help.                 |
| `yanky.nvim`                               | Yank history and paste cycling.                             |

## Configuration layout

| Path              | Purpose                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------- |
| `init.lua`        | Sets the leader keys and loads the configuration.                                             |
| `lua/config/`     | Native options, keymaps, autocmds, LSP, sessions, statusline, tabline, and filetype behavior. |
| `lua/plugins/`    | Plugin installation and setup. Each plugin has its own Lua file.                              |
| `after/ftplugin/` | Filetype overrides that load after Neovim's built-in filetype plugins.                        |
| `examples/dap/`   | Project-local `.nvim.lua` templates for C and Python debugging.                               |

`lua/config/init.lua` lists the native modules. `lua/plugins/init.lua` lists
the plugin modules and their load order.

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone
git clone https://github.com/ppalazon/nvim.git ~/.config/nvim

# Launch (plugins install automatically)
nvim
```

Prerequisites: Neovim 0.13+, Git, Ripgrep, Nerd Font

Update plugins: `<leader>Pu` or `:lua vim.pack.update()`

## Keymaps

Leader key: Space

### Files and search

```text
<leader><space>     Smart file picker
<leader>/           Grep picker
<leader>e           Open or switch focus between the file explorer and its main buffer
<S-F1>              Show or hide the file explorer without focusing it when opening
<leader>,           Buffer picker
<leader>fb          Buffer picker
<leader>fc          Find configuration files
<leader>ff          Find files
<leader>fg          Find Git-tracked files
<leader>fp          Project picker
<leader>fr          Recent files
<leader>fn          New buffer
<leader>fd          Open the current buffer directory in Thunar
<leader>fD          Open the project root in Thunar
<leader>fCf         Copy full path
<leader>fCn         Copy file name
<leader>fCr         Copy path relative to the current directory
<leader>sb          Search buffer lines
<leader>sB          Grep open buffers
<leader>sw          Grep the word or visual selection
<leader>s/          Search history
<leader>sc          Command history
<leader>sC          Commands picker
<leader>sR          Resume the last picker
<leader>sr          Search and replace across files
```

### Snacks Explorer

```text
<S-h> Toggle hidden files
<S-i> Toggle ignored files
<S-f> Toggle follow mode
<C-y> Copies the selected file's relative path
O     Opens the current directory in Thunar
```

### Buffers

```text
<Tab>, ]b, <S-l>, <leader>bn       Next buffer
<S-Tab>, [b, <S-h>, <leader>bp     Previous buffer
<leader>bb                         Switch to the alternate buffer
<leader>bd                         Delete the current buffer
<leader>ba                         Delete all buffers
<leader>bo                         Delete all other buffers
<leader>bl                         Close buffers to the left
<leader>br                         Close buffers to the right
```

In the buffer picker, `dd` or `<C-d>` deletes the selected buffer.

### Windows

```text
<C-h/j/k/l>              Move to the left, lower, upper, or right window
<C-S-Up/Down>            Increase or decrease window height
<C-S-Left/Right>         Decrease or increase window width
<leader>ww               Previous window
<leader>wd               Close window
<leader>wo               Close other windows
<leader>w=               Equalize window sizes
<leader>wH/J/K/L         Move window left, bottom, top, or right
<leader>w-, <leader>sh   Split below
<leader>w|, <leader>|    Split right
<leader>`, <leader>sv    Split right
```

In a terminal, `<Esc><Esc>` enters Normal mode, `<C-h/j/k/l>` changes windows,
and `<C-/>` closes the terminal window.

### Tabs

```text
<leader><Tab><Tab>       New tab
<leader><Tab>]           Next tab
<leader><Tab>[           Previous tab
<leader><Tab>f           First tab
<leader><Tab>l           Last tab
<leader><Tab>d           Close tab
<leader><Tab>o           Close other tabs
```

### Headers

```text
<leader>ra               Add an SPDX header
```

### LSP (native)

```text
<leader>ca               Code actions
<leader>cr               Rename symbol
<leader>k, K             Hover documentation
gd                       Go to definition
<leader>cf               Formats the current buffer (Conform)
```

The Snacks LSP pickers are available globally:

```text
gD                        Declarations
grr                       References
gI                        Implementations
gy                        Type definitions
<leader>ss, <leader>sS    Document and workspace symbols
gai, gao                  Incoming and outgoing calls
```

### Tree-sitter text object

```text
ai, ii                    Conditional or its inner part
al, il                    Loop or its body
a=, i=                    Assignment or its inner part
aC, iC                    Function call or its arguments
aR, iR                    Return statement or its returned expression
```

### Git

```text
]h, [h                    Next or previous hunk
]H, [H                    Last or first hunk
<leader>ghs, <leader>ghr  Stage or reset hunk
<leader>ghS, <leader>ghR  Stage or reset buffer
<leader>ghu               Undo staged hunk
<leader>ghp               Preview hunk inline
<leader>ghb, <leader>ghB  Line or buffer blame
<leader>ghd, <leader>ghD  Diff current buffer against the index or ~
ih                        Select hunk text object

<leader>gb                Branch picker
<leader>gl, <leader>gL    Repository or current-line log
<leader>gs, <leader>gS    Status or stash picker
<leader>gp, <leader>gP    Diff picker against HEAD or origin
<leader>gf                Current-file Git log
<leader>gB                Open the remote Git URL
<leader>gg                Open LazyGit
<leader>gd                Open Diffview status
<leader>gv, <leader>gV    Repository or current-file history in Diffview
<leader>gc, <leader>gC    Compare revisions or file history range
<leader>g2                Compare two files
```

### Debug

```text
<leader>dc, <F6>          Continue
<leader>db, <F8>          Toggle breakpoint
<leader>dB                Set conditional breakpoint
<leader>dC                Run to cursor
<leader>di, <leader>do    Step into or over
<leader>dO                Step out
<F9>, <F10>, <F11>        Step over, into, or out
<leader>dj, <leader>dk    Move down or up the stack frames
<leader>dl                Run the last configuration
<leader>dL                List breakpoints
<leader>dP, <leader>dt    Pause or terminate
<leader>dr, <leader>du    Toggle the REPL or DAP UI
<leader>de                Evaluate the expression or selection
<leader>dw                Add the visual selection to watches
<leader>dx                Clear breakpoints
```

### Diagnostics

```text
<leader>cd                Show diagnostics for the current line
]d, [d                    Next or previous diagnostic
]e, [e                    Next or previous error
]w, [w                    Next or previous warning
<leader>sd, <leader>sD    Workspace or current-buffer diagnostic picker
```

### Quickfix and location

```text
<leader>xq                Toggle quickfix list
<leader>xl                Toggle location list
]q, [q                    Next or previous quickfix item
<leader>sq                Quickfix picker
<leader>sl                Location-list picker
q                         Close a quickfix buffer.
```

### Markdown

```text
<CR>, <A-CR> (Insert)     Continue a list item or its content
<Tab>, <S-Tab> (Insert)   Indent or outdent a list item
<BS> (Insert)             Remove an empty list marker
<C-t> (Insert)            Toggle a task checkbox
o, O                      Add a list item below or above
<leader>mr, <leader>mx    Renumber a list or toggle a checkbox
<leader>lt{u,t,n,N,l,L,p,P,c} Toggle or clear a list type
<leader>m{b,i,S,`,=,u,F}  Change inline text formatting
<leader>me (Visual)       Escape Markdown punctuation
<leader>mc                Insert or wrap a fenced code block
<leader>mC                Change the current code block language
]B, [B                    Next or previous fenced code block
]], [[                    Next or previous heading
<leader>h{+,-,1-6}        Change heading level
<leader>h{t,u,T}          Generate, update, or open the table of contents
<leader>hg                Follow a table-of-contents link
<leader>ms                Toggle ATX or setext heading style
<leader>mh, <leader>mH    Insert or change a thematic break
<leader>m{l,e,a,R,I,p}    Create, edit, or convert links
<leader>m{L,E,A}          Create, edit, or convert images
<leader>mq                Toggle a blockquote
<leader>mQ{i,t,c,b}       Insert, change, or convert a callout
<leader>mf{i,e,d,g,r,n,p,l} Manage footnotes
<leader>T{c,f,n}          Create, format, or normalize a table
<leader>Ti{r,R,c,C}       Insert a table row or column
<leader>Td{r,c}           Delete a table row or column
<leader>Ty{r,c}           Duplicate a table row or column
<leader>T{a,x,b,w,W,e}    Edit the current table cell
<leader>Tm{j,k,h,l}       Move a table row or column
<leader>T{t,sa,sd,vx,vi}  Transpose, sort, or convert a table
<A-h/j/k/l> (Insert)      Move between table cells
<leader>ci                Paste image into a Markdown buffer
<leader>cp                Preview the current Markdown file with mdserve
<leader>um                Toggle Markdown rendering
```

### Sessions

```text
<leader>qs                Load the current-directory session
<leader>ql                Load the last session
<leader>qS                Select and load a session
<leader>qd                Skip saving the next session
<leader>qr                Delete the current-directory session
```

### vim.pack

```text
<leader>Pu                Update all packages
<leader>Pd                Delete a package
```

### UI toggles

```text
<leader>tw                Toggle line wrapping
<leader>uf                Toggle autoformat on save
<leader>use               Enable Neovim English spelling
<leader>uss               Enable Neovim Spanish spelling
<leader>uso               Disable spelling and detach Harper
<leader>ush               Toggle Harper grammar checking
<leader>uC                Select a color scheme
<leader>ui                Inspect the position under the cursor
<leader>uI                Inspect the syntax tree under the cursor
<leader>ur                Redraw and clear search highlighting
<leader>z, <leader>Z      Toggle Zen mode or Zen zoom
<leader>., <leader>S      Open a scratch buffer or scratch selector
```

### Tasks

```text
<F5>, <leader>or          Run a project task
<leader>os                Run a shell command
<leader>ot                Toggle the task list
<leader>oa                Select a task action
<leader>oq                Close the task list
```

### OpenCode

```text
<leader>aa                Ask OpenCode about the cursor or selection
<leader>ai (Normal)       Ask OpenCode to insert at the cursor
<leader>ai (Visual)       Ask OpenCode to replace the selection
<leader>ae                Give OpenCode a project-wide task
<leader>as                Select a session on the connected server
<leader>ao                Open or show the persistent OpenCode terminal
<leader>ac                Hide the OpenCode terminal without stopping its session
<F3>                      Toggle the persistent OpenCode terminal
```

Edit request opens a buffer-local diff review in a new tab:

```text
da, dr                    Accept or reject the complete OpenCode edit
dp, do                    Accept or reject the hunk under the cursor
]c, [c                    Next or previous change
q                         Close the edit review
```

## Debugging

The configuration uses `nvim-dap` and `nvim-dap-ui`. Mason installs `codelldb`
and `debugpy`. The DAP setup looks for `codelldb` and `debugpy-adapter` on
`PATH`, then in Mason's `bin` directory.

Launch settings belong to each project. Add a `.nvim.lua` file to the project
root and adapt one of these templates:

- `examples/dap/c/.nvim.lua` sets the compiled executable and optional
  arguments.
- `examples/dap/python/.nvim.lua` sets the application entry script. It uses
  `.venv/bin/python` when available, otherwise `python3` from `PATH`.

Neovim asks before loading a project-local configuration. Use `<leader>pc` to
open `.nvim.lua`, review it, then use `<leader>pt` in that buffer to trust it.
Use `<leader>pu` to mark it as untrusted. `:trust` also changes the saved
decision.

## License

MIT

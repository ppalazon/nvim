vim.pack.add({
  "https://github.com/attilarepka/header.nvim",
})

local header = require("header")
local languages = require("header.languages")
local renderer = require("header.renderer")

-- header.languages and header.renderer are internal to header.nvim, kept for
-- insertion placement and comment styles that :Header also relies on.
header.setup({
  date_created = false,
  date_modified = false,
  file_name = false,
  line_separator = false,
  use_block_header = false,
})

local common_licenses = {
  "MIT",
  "Apache-2.0",
  "BSD-2-Clause",
  "BSD-3-Clause",
  "GPL-2.0-only",
  "GPL-2.0-or-later",
  "GPL-3.0-only",
  "GPL-3.0-or-later",
  "LGPL-2.1-only",
  "LGPL-2.1-or-later",
  "LGPL-3.0-only",
  "LGPL-3.0-or-later",
  "AGPL-3.0-only",
  "AGPL-3.0-or-later",
  "MPL-2.0",
  "ISC",
  "CC0-1.0",
  "Unlicense",
  "Zlib",
}

local custom_license = "Custom SPDX expression..."
local copyright_tag = "SPDX-FileCopyrightText:"
local identifier_tag = "SPDX-License-Identifier:"

local function project_root()
  return vim.fs.root(0, { ".git" }) or vim.uv.cwd()
end

local function license_file(root)
  local candidates = {}
  local ok, iterator = pcall(vim.fs.dir, root)
  if not ok or not iterator then
    return nil
  end

  for name, type in iterator do
    local is_license = name == "LICENSE"
      or name == "LICENCE"
      or name:match("^LICENSE[._%-].+")
      or name:match("^LICENCE[._%-].+")
    if type == "file" and is_license then
      table.insert(candidates, name)
    end
  end

  table.sort(candidates, function(a, b)
    if a == "LICENSE" then
      return true
    end
    if b == "LICENSE" then
      return false
    end
    if a == "LICENCE" then
      return true
    end
    if b == "LICENCE" then
      return false
    end
    return a < b
  end)

  return candidates[1] and vim.fs.joinpath(root, candidates[1]) or nil
end

local function detect_license(root)
  local path = license_file(root)
  if not path then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, path, "", 1000)
  if not ok then
    return nil
  end

  for _, line in ipairs(lines) do
    local at = line:lower():find(identifier_tag:lower(), 1, true)
    if at then
      local identifier = vim.trim(line:sub(at + #identifier_tag):gsub("%s*%*/%s*$", ""))
      if identifier ~= "" then
        return identifier
      end
    end
  end

  local text = table.concat(lines, "\n"):lower()
  local signatures = {
    {
      "Apache-2.0",
      { "apache license", "version 2.0, january 2004" },
    },
    {
      "AGPL-3.0-only",
      { "gnu affero general public license", "version 3" },
    },
    {
      "LGPL-3.0-only",
      { "gnu lesser general public license", "version 3" },
    },
    {
      "LGPL-2.1-only",
      { "gnu lesser general public license", "version 2.1" },
    },
    {
      "GPL-3.0-only",
      { "gnu general public license", "version 3" },
    },
    {
      "GPL-2.0-only",
      { "gnu general public license", "version 2" },
    },
    {
      "MPL-2.0",
      { "mozilla public license", "version 2.0" },
    },
    {
      "CC0-1.0",
      { "cc0 1.0 universal", "public domain" },
    },
    {
      "Unlicense",
      { "this is free and unencumbered software released into the public domain" },
    },
    {
      "BSD-3-Clause",
      { "redistribution and use in source and binary forms", "neither the name of" },
    },
    {
      "BSD-2-Clause",
      { "redistribution and use in source and binary forms", "redistributions in binary form" },
    },
    {
      "ISC",
      { "permission to use, copy, modify, and/or distribute this software for any purpose with or without fee" },
    },
    {
      "MIT",
      { "permission is hereby granted, free of charge, to any person obtaining a copy" },
    },
    {
      "Zlib",
      { "this software is provided 'as-is'", "altered source versions must be plainly marked" },
    },
  }

  for _, signature in ipairs(signatures) do
    local matches = true
    for _, fragment in ipairs(signature[2]) do
      if not text:find(fragment, 1, true) then
        matches = false
        break
      end
    end
    if matches then
      return signature[1]
    end
  end
end

local function git_author(root)
  local result = vim.system({ "git", "-C", root, "config", "user.name" }, { text = true }):wait()
  local author = result.code == 0 and vim.trim(result.stdout or "") or ""
  return author ~= "" and author or "Pablo Palazon"
end

local function resolve_language()
  local by_extension = languages[vim.fn.expand("%:e")]
  local language = by_extension or languages.filetypes[vim.bo.filetype] or languages[vim.bo.filetype]
  return language and language() or nil
end

local function comment_terminator(line)
  local suffix = line:match("(%s*%*/%s*)$")
    or line:match("(%s*%-%->%s*)$")
    or line:match("(%s*%]%]%s*)$")
  return suffix or ""
end

local function find_tag(lines, tag)
  for index, line in ipairs(lines) do
    local at = line:lower():find(tag:lower(), 1, true)
    if at then
      return index, line:sub(1, at - 1), comment_terminator(line)
    end
  end
end

local function tagged(prefix, terminator, tag, value)
  return prefix .. tag .. " " .. value .. terminator
end

local function set_line(index, text)
  vim.api.nvim_buf_set_lines(0, index - 1, index, false, { text })
end

local function insert_line(index, text)
  vim.api.nvim_buf_set_lines(0, index - 1, index - 1, false, { text })
end

local function apply_spdx_header(identifier, author)
  local language = resolve_language()
  if not language then
    vim.notify("unsupported file type for SPDX header", vim.log.levels.ERROR)
    return
  end

  identifier = vim.trim(identifier or "")
  if identifier == "" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local copyright_at, copyright_prefix, copyright_end = find_tag(lines, copyright_tag)
  local identifier_at, identifier_prefix, identifier_end = find_tag(lines, identifier_tag)

  if identifier_at then
    set_line(identifier_at, tagged(identifier_prefix, identifier_end, identifier_tag, identifier))

    if not copyright_at then
      insert_line(identifier_at, tagged(identifier_prefix, identifier_end, copyright_tag, ("%d %s"):format(os.date("%Y"), author)))
    end
  elseif copyright_at then
    insert_line(copyright_at + 1, tagged(copyright_prefix, copyright_end, identifier_tag, identifier))
  else
    local placement = language.resolve_insertion(lines)
    if not placement.ok then
      vim.notify(placement.error, vim.log.levels.ERROR)
      return
    end

    local style = placement.comment_style or language.comment_style
    local rendered = renderer.render_header({
      ("%s %d %s"):format(copyright_tag, os.date("%Y"), author),
      identifier_tag .. " " .. identifier,
    }, style, false)

    local following = lines[placement.insert_line + 1]
    if following and following:match("^%s*$") then
      table.remove(rendered)
    end

    vim.api.nvim_buf_set_lines(0, placement.insert_line, placement.insert_line, false, rendered)
  end
end

local function select_license()
  local root = project_root()
  local detected = detect_license(root)
  local author = git_author(root)
  local choices = {}

  if detected then
    table.insert(choices, detected)
  end
  for _, identifier in ipairs(common_licenses) do
    if identifier ~= detected then
      table.insert(choices, identifier)
    end
  end
  table.insert(choices, custom_license)

  vim.ui.select(choices, {
    prompt = "SPDX license identifier:",
    format_item = function(identifier)
      return identifier == detected and (identifier .. " (detected)") or identifier
    end,
  }, function(identifier)
    if not identifier then
      return
    end
    if identifier == custom_license then
      vim.ui.input({ prompt = "SPDX expression: " }, function(input)
        apply_spdx_header(vim.trim(input or ""), author)
      end)
      return
    end
    apply_spdx_header(identifier, author)
  end)
end

vim.keymap.set("n", "<leader>ra", select_license, { desc = "Add SPDX header" })
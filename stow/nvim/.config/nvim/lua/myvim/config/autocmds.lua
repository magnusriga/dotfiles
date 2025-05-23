--[[
=============================================
Autocommands
=============================================
- See `:help lua-guide-autocommands`.
- This file is automatically loaded by `vim.config.init`.
=============================================
--]]

-- Create new autocommand group on demad, prefixed with `myvim_`.
local function augroup(name)
  return vim.api.nvim_create_augroup("myvim_" .. name, { clear = true })
end

-- Check if any buffers were changed outside of Vim, e.g. in `yazi`|terminal,
-- and give warning if saving will result in two files.
-- Event(s):
-- - `FocusGained`: When Neovim gains focus.
-- - `TermClose`: When terminal job ends.
-- - `TermLeave`: When leaving terminal mode.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Resize splits if window got resized.
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last `loc` when opening buffer.
-- `"` mark, i.e. quote mark, holds cursor position when last exiting current buffer,
-- saved by Neovim between restarts.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].myvim_last_loc then
      return
    end
    vim.b[buf].myvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close certain filetypes with `q`, like help -and lspinfo buffers.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "Avante",
    "AvanteInput",
    "AvanteSelectedFiles",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "PlenaryTestPopup",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- When file name ends with `man`, remove it from buffer list when file is opened.
-- Makes it easier to close man-files when opened inline.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Enable `opt.wrap` and `opt.spell` on text files, e.g. `txt`, `markdown`, etc.
-- `wrap` is always enabled anyways, see: `config/options.lua`.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for `json` files.
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create directory when saving file, in case intermediate directory does not exist.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Disable `treesitter-context` for certain filetypes.
local disabled_filetypes = { "markdown", "help", "txt" }
local context_group = vim.api.nvim_create_augroup("TreesitterContextToggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = context_group,
  callback = function()
    local current_ft = vim.bo.filetype
    if vim.tbl_contains(disabled_filetypes, current_ft) then
      require("treesitter-context").disable()
    else
      require("treesitter-context").enable()
    end
  end,
})

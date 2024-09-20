vim.g.mapleader = " "

-- Makes vim more useful
vim.o.backspace = 'indent,eol,start'
vim.o.cmdheight = 2
vim.o.encoding = 'utf-8'
vim.o.wrap = false

vim.o.colorcolumn = '80'

vim.o.syntax = "on"
--vim.bo.filetype = 'plugin on'

vim.g.airline_theme='murmur'

-- Better file navigation
vim.o.path = vim.o.path .. "**"
vim.o.wildmenu = true
vim.o.hidden = true

-- Correct splitting windows
vim.o.splitbelow = true
vim.o.splitright = true

-- Searching
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- When no filetype specified indents at same level from previous
vim.o.autoindent = true

-- Display the cursor position on the last line of the screen or in the status
-- line of a window
vim.o.ruler = true
vim.o.laststatus = 2

-- Let not beeping nor flashing when doing something wrong
vim.o.visualbell = true
-- t_vb obsolete in Neovim
-- vim.o.t_vb = ""

-- Enable use of the mouse for all modes
vim.o.mouse = 'a'

-- UI - More beauty
vim.o.number = true
vim.o.relativenumber = false
vim.o.showcmd = true
vim.o.cursorline = true
vim.o.signcolumn = 'yes'

--  Instead of failing a command because of unsaved changes, instead raise asking
--  asking if you wish to save changed files.
vim.o.confirm = true

-- Use bracketed paste (Toggle paste and nopaste is obsolete in Neovim)
-- vim.o.pastetoggle = '<F2>'

-- Tabs and spaces
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

-- Undo
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

-- Show spaces
vim.o.list = true
vim.o.listchars = "tab:>-,space:·"

-- Copy to clipboard
vim.o.clipboard=unnamedplus
vim.api.nvim_set_option("clipboard", "unnamedplus")

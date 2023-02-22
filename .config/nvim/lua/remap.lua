vim.g.mapleader = " "

local map = vim.keymap.set

--map("n", "<leader>pv", vim.cmd("Ex"))

-- No arrow kays for learning
map("n", "<left>", "<NOP>")
map("n", "<down>", "<NOP>")
map("n", "<up>", "<NOP>")
map("n", "<right>", "<NOP>")

-- Vertical resize
map("n", "<leader>+", ":vertical resize +5<cr>")
map("n", "<leader>-", ":vertical resize -5<cr>")

-- Move text
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Alias to to quit and save faster
map("n", "<leader>q", ":q<cr>")
map("n", "<leader>w", ":w<cr>")

-- Alias to split window with a new file
map("n", "<leader>h", ":split<Space>")
map("n", "<leader>v", ":vsplit<Space>")

-- Alias to split window with a new file
-- <C-w>h == :wincmd h<CR>
map("n", "<leader>h", ":wincmd h<cr>")
map("n", "<leader>j", ":wincmd j<cr>")
map("n", "<leader>k", ":wincmd k<cr>")
map("n", "<leader>l", ":wincmd l<cr>")

-- Alias to substite al occurrences
map("n", "<leader>s", ":%s//gI<left><left><left>")

-- Awesome Remaps
-- Now undo breaks without exiting insert mode an loose everything you wrote
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", "?", "?<c-g>u")
map("i", "!", "!<c-g>u")
map("i", "]", "]<c-g>u")

-- Yank to clipboard
map("n", "<leader>y", '"+y')
map("v", "<leader>y", '"+y')

-- Same as D or C, so it is more intuitive
map("n", "Y", 'y$')

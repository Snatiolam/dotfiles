vim.g.mapleader = " "

local map = vim.keymap.set

--map("n", "<leader>pv", vim.cmd("Ex"))

-- No arrow kays for learning
map("n", "<left>", "<NOP>")
map("n", "<down>", "<NOP>")
map("n", "<up>", "<NOP>")
map("n", "<right>", "<NOP>")

map("n", "<C-n>", ":NvimTreeToggle<CR>")
map("n", "<C-u>", ":UndotreeToggle<CR>")

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

-- Get rid of search highlights
map("n", "<leader>/", ":nohlsearch<cr>", { silent = true })

-- fzf keymaps
map("n", "<leader>p", ":Files<CR>")
map("n", "<leader>ob", ":Buffers<CR>")

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

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

-- ============
-- Autocommands
-- ============
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})


-- Highlight yanked text
vim.api.nvim_create_autocmd(
  'TextYankPost',
  {
    pattern = '*',
    command = 'silent! lua vim.highlight.on_yank({ timeout = 500 })'
  }
)

-- Open the Chat Sidebar
vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })

-- Inline rewrite (Highlight code and hit <leader>ai)
vim.keymap.set({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })

-- Add selected code to the current chat
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

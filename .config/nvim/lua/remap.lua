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
map("n", "<leader>sp", ":split<Space>")
map("n", "<leader>v", ":vsplit<Space>")

-- Navigate between windows
-- <C-w>h == :wincmd h<CR>
map("n", "<leader>h", ":wincmd h<cr>")
map("n", "<leader>j", ":wincmd j<cr>")
map("n", "<leader>k", ":wincmd k<cr>")
map("n", "<leader>l", ":wincmd l<cr>")

-- Alias to substite al occurrences
map("n", "<leader>s", ":%s//gI<left><left><left>")

-- Get rid of search highlights
map("n", "<leader>/", ":nohlsearch<cr>", { silent = true })

-- Note: file tree (<C-n>), undotree (<C-u>), telescope and codecompanion
-- keymaps live in their plugin specs (lua/plugins/*.lua) so the plugins
-- load only when those keys are pressed.

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
        -- Skip special buffers (help, quickfix, plugin scratch...): fixing
        -- whitespace there fails with E21 and just shows a noisy error.
        if not vim.bo.modifiable or vim.bo.readonly or vim.bo.buftype ~= "" then
            return
        end
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


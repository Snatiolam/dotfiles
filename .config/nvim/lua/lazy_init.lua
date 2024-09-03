local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        -- "morhetz/gruvbox",
        -- "folke/tokyonight.nvim",
        -- "tanvirtin/monokai.nvim",
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme tokyonight-storm")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function () 
          local configs = require("nvim-treesitter.configs")

          configs.setup({
              ensure_installed = { "c", "java", "lua", "vim", "vimdoc", "rust", "typescript", "javascript", "html" },
              sync_install = false,
              highlight = { enable = true },
              -- indent = { enable = true },  
            })
        end
    },
    {"vim-airline/vim-airline"},
    {"vim-airline/vim-airline-themes"},
    {"jiangmiao/auto-pairs"},
    {"L3MON4D3/LuaSnip"},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {
	'junegunn/fzf.vim',
        dependencies = {
		{ 'junegunn/fzf', dir = '~/.fzf', build = './install --all' },
        },
    },
    {"mbbill/undotree"},
    {"preservim/nerdtree"},
    {"nvim-java/nvim-java"},
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },
})

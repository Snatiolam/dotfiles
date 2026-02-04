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
      local configs = require("nvim-treesitter")

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
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
  {
    'junegunn/fzf.vim',
    dependencies = {
      { 'junegunn/fzf', dir = '~/.fzf', build = './install --all' },
    },
  },
  {"mbbill/undotree"},
  -- "preservim/nerdtree"},
  -- Consider using CHADTree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    config = function()
      require("nvim-tree").setup {}
    end,
  },
  {"nvim-java/nvim-java"},
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For autocompletion
      "nvim-telescope/telescope.nvim", -- Optional: For fuzzy finding
    },
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = "GEMINI_API_KEY",
              },
              schema = {
                model = {
                  default = "gemini-2.5-flash",
                },
              },
            })
          end,
        }
      },
      interactions = {
        chat = {
          adapter = "gemini",
          model = "gemini-2.5-flash",
        },
        inline = {
          adapter = "gemini",
          model = "gemini-2.5-flash",
        },
      },
      opts = {
        log_level = "DEBUG",
      },

    },
  }
})

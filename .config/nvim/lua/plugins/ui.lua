return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },

  {
    "vim-airline/vim-airline",
    event = "VeryLazy",
    dependencies = { "vim-airline/vim-airline-themes" },
  },

  {
    "jiangmiao/auto-pairs",
    event = "InsertEnter",
  },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({})
    end,
  },

  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<C-u>", "<cmd>UndotreeToggle<cr>", desc = "Toggle undotree" },
    },
  },
}

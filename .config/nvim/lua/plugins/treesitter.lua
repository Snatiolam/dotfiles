return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = { "lua", "python", "go", "c", "vim", "vimdoc", "typescript", "javascript", "html" }

      require("nvim-treesitter").setup({})

      local installed = require("nvim-treesitter.config").get_installed()
      local missing = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed, parser)
      end, parsers)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}

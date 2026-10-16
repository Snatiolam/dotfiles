return {
  {
    "olimorris/codecompanion.nvim",
    -- AI is opt-in: load only when one of its commands/keys is used
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionCmd",
      "CodeCompanionToggle",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For autocompletion
      "nvim-telescope/telescope.nvim", -- Optional: For fuzzy finding
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle AI chat" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "Inline AI rewrite" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to chat" },
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
        },
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
  },
}

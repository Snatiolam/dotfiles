return {
  {
    "neovim/nvim-lspconfig",
    ft = { "lua", "python", "go", "c", "cpp", "rust" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "gopls",
          "rust_analyzer",
          -- "clangd",
          -- "jdtls",
        },
        automatic_enable = false,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(event)
          local opts = { buffer = event.buf, silent = true }

          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

          -- Documentation
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

          -- Actions
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)

          -- Workspace
          vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)

          -- Diagnostics
          vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "<space>[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "<space>]d", vim.diagnostic.goto_next, opts)
        end,
      })

      local servers = {
        -- LUA
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        -- PYTHON
        pyright = {
          settings = { python = { analysis = { typeCheckingMode = "basic" } } },
        },
        -- GO
        gopls = {
          settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true, gofumpt = true } },
        },
        -- RUST
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              -- `checkOnSave` was deprecated; the modern key is `check`
              -- (runs on save by default, with `check.command` as the linter)
              check = { command = "clippy" },
              procMacro = { enable = true },
            },
          },
        },
        -- C / C++
        clangd = {
          -- Generate compile_commands.json with 'bear -- make'
          cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
        },
      }

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
      end

      -- Enable only once the configs above are registered. With `ft` lazy
      -- loading this runs with the filetype already set, so vim.lsp.enable()
      -- attaches to the current buffer as well.
      vim.lsp.enable({ "lua_ls", "pyright", "gopls" })

      -- Not installed via mason: enable them only if the binary exists
      for server, exe in pairs({ clangd = "clangd", rust_analyzer = "rust-analyzer" }) do
        if vim.fn.executable(exe) == 1 then
          vim.lsp.enable(server)
        end
      end
    end,
  },
}

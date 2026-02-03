-- ============
-- Dependencies
-- ============

require('java').setup()

local luasnip = require 'luasnip'
local cmp = require 'cmp'

-- Deprecated
-- local lspconfig = require('lspconfig')

-- Install servers
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "clangd",
        "pyright",
        "jdtls"
    },
})

-- ==============
-- Autocompletion
-- ==============

cmp.setup {
    snippet = {
      -- REQUIRED - must specify a snippet engine (luasnip)
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
            else
            fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

-- ===========
-- Capabilites
-- ===========

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- ===========
-- Keybindings
-- ===========

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(event)
        local opts = { buffer = event.buf, silent = true }

        -- Navigation
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

        -- Documentation
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

        -- Actions
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<space>f', function() 
            vim.lsp.buf.format { async = true } 
        end, opts)

        -- Workspace
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    end,
})

-- =====================
-- Server configurations
-- =====================

local servers = {
    -- LUA
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                -- Tell the language server which version of Lua you're using
                version = 'LuaJIT',
                },
                diagnostics = {
                    globals = { 'vim' }
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false
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
                checkOnSave = { command = "clippy" },
                procMacro = { enable = true },
            },
        },
    },
    -- C / C++
    clangd = {
        -- Generate compile_commandsjson with 'bear -- make'
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
    },
}

for name, config in pairs(servers) do
  config.capabilites = capabilities
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

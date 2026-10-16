-- Bootstrap lazy.nvim
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

-- NOTE: this file is named `lazy.lua`, which shadows lazy.nvim's own `lazy`
-- module, so `require("lazy")` would load this very file again and Lua aborts
-- with "loop or previous error loading module 'lazy'". Load the plugin entry
-- point directly and return it, so `require("lazy")` resolves to the real
-- module for the rest of the session. (Naming this file e.g. `bootstrap.lua`
-- would avoid the shadowing entirely.)
local lazy = dofile(lazypath .. "/lua/lazy/init.lua")

-- Plugin specs live in lua/plugins/*.lua, one file per concern.
lazy.setup({
  spec = {
    { import = "plugins" },
  },
  performance = {
    rtp = {
      -- Runtime plugins we never use; skipping them saves startup time.
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

return lazy

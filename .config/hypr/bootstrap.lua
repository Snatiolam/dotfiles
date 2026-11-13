-- Hyprland caches Lua modules across reloads; clear ours so edits apply.
local home = os.getenv("HOME")
local reload_prefixes = { "hypr" }

local function should_reload(module)
    for _, prefix in ipairs(reload_prefixes) do
        if module == prefix or module:sub(1, #prefix + 1) == prefix .. "." then
            return true
        end
    end

    return false
end

for module in pairs(package.loaded) do
    if should_reload(module) then
        package.loaded[module] = nil
    end
end

package.path = home .. "/.config/?.lua;" .. package.path

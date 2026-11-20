------------------
---- LAUNCHER ----
------------------

local M = {}

function M.launch_or_focus(class, command)
    return function()
        for _, window in ipairs(hl.get_windows()) do
            if window.class == class then
                hl.dispatch(hl.dsp.focus({ window = window }))
                return
            end
        end
        hl.exec_cmd(command)
    end
end

return M

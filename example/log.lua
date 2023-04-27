local M = {}

local MAX_LOG_LINES = 24

local gprint = print
local log = {}
local text = ""
_G.print = function(...)
    gprint(...)
    local args = {...}
    local num = #log+1
    log[num] = "--"
    for k, v in pairs(args) do
        log[num] = log[num] .. tostring(v) .. " "
    end
    log[num] = log[num] .. "\n"
    text = ""
    if num > MAX_LOG_LINES then
        table.remove(log, 1)
    end
    for k, v in pairs(log) do
        text = text .. v
    end
end

function M.update(node)
    gui.set_text(node, text)
end

function M.print_all_sdk_ent()
    print("----ALL-SDK-entities----")
    for k, v in pairs(_G.ironsource) do
        if type(v) == "function" then
            v = "()"
        else
            v = "="..tostring(v)
        end
        print(k..v)
    end
    print("----")
end

return M

local M = {}

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
end

local function get_text()
    text = ""
    for k, v in pairs(log) do
        text = text .. v
    end
end

function M.update(node)
    local font_name = gui.get_font(node)
    local font = gui.get_font_resource(font_name)
    local size = gui.get_size(node)
    get_text()
    local metrics_opt = {width = size.x, line_break = true}
    local metrics = resource.get_text_metrics(font, text, metrics_opt)
    while metrics.height > size.y do
        table.remove(log, 1)
        get_text()
        metrics = resource.get_text_metrics(font, text, metrics_opt)
    end
    gui.set_text(node, text)
end

local all_msgs = {}
local all_events = {}

local function save_const(key, value)
    if string.find(key, "EVENT") then
        all_events[value] = key
    elseif string.find(key, "MSG") then
        all_msgs[value] = key
    end
end

function M.print_all_sdk_ent()
    print("----ALL-SDK-entities----")
    for k, v in pairs(_G.ironsource) do
        if type(v) == "function" then
            v = "()"
        else
            save_const(k, v)
            v = "="..tostring(v)
        end
        print(k..v)
    end
    print("----")
end

function M.msg(const)
    return all_msgs[const]
end

function M.event(const)
    return all_events[const]
end

local function is_ignore(key, ignore)
    if not ignore then 
        return false
    end
    for k, v in pairs(ignore) do
        if key == v then
            return true
        end
    end
    return false
end

function M.get_table_as_str(table, ignore)
    if not table then
        return nil
    end
    local result = ""
    for k, v in pairs(table) do
        if not is_ignore(k, ignore) then
            result = result..tostring(k)..":"..tostring(v)..", "
        end
    end
    if result ~= "" then
        return result
    end
    return nil
end

return M

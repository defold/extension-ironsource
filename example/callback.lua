local log = require("example.log")

local M = {}

local function ironsource_callback(self, message_id, message)
    print("cbk: "..log.msg(message_id).." "..log.event(message.event))
    local msg = log.get_table_as_str(message)
    if msg then
        print("msg: "..msg)
    end
end

function M.set()
    ironsource.set_callback(ironsource_callback)
end

return M
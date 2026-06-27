local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local slot_logic = require "logic.slot"
local response = require "common.response"

local CMD = {}

function CMD.spin(uid, game_id, bet)
    local data, err = slot_logic.spin(uid, game_id, bet)

    if err then
        return response.error(err.code, err.msg)
    end

    return response.success(data)
end

skynet.start(function()

    skynet.error("[SLOT] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        assert(f, "unknown cmd : " .. tostring(cmd))
        
        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".slot")
end)
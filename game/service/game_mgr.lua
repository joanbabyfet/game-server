local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local game_logic = require "logic.game"
local response = require "common.response"

local CMD = {}

function CMD.list()

    local data, err = game_logic.list()

    if err then
        return response.error(err.code, err.msg)
    end

    return response.success(data)
end

function CMD.info(game_id)

    local data, err = game_logic.info(game_id)

    if err then
        return response.error(err.code, err.msg)
    end

    return response.success(data)
end

-- 负责游戏运行时状态, 比如注册游戏/获取游戏/游戏开关/游戏维护/游戏实例管理/最小下注/最大下注
skynet.start(function()

    skynet.error("[GAME] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        assert(f, "unknown cmd : " .. tostring(cmd))

        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".game_mgr")
end)
local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local game_logic = require "logic.game"
local constant = require "common.constant"

local CMD = {}

function CMD.list()

    local data, err = game_logic.list()

    if err then
        return nil, err
    end

    return data
end

function CMD.info(game_id)

    local data, err = game_logic.info(game_id)

    if err then
        return nil, err
    end

    return data
end

-- 负责游戏运行时状态, 比如注册游戏/获取游戏/游戏开关/游戏维护/游戏实例管理/最小下注/最大下注
skynet.start(function()

    skynet.error("[GAME_MGR] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]
        
        if not f then
            skynet.error(string.format(
                "[GAME_MGR] unknown cmd=%s source=%08x",
                tostring(cmd),
                source
            ))

            skynet.retpack(nil, {
                code = constant.ERROR.RPC_UNKNOWN_CMD,
                msg = "unknown cmd",
            })

            return
        end

        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".game_mgr")
end)
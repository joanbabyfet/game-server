local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local slot_logic = require "logic.slot"
local response = require "common.response"

local CMD = {}

local config_mgr = skynet.localname(".config_mgr")

-- 普通旋转
function CMD.spin(uid, agent_id, game_id, bet)
    -- 游戏配置
    local cfg = skynet.call(
        config_mgr,
        "lua",
        "get_game",
        game_id
    )

    if not cfg then
        return response.error(-2002, "game not found")
    end

    if cfg.status ~= 1 then
        return response.error(-2008, "game disabled")
    end

    if cfg.maintenance == 1 then
        return response.error(-2009, cfg.maintenance_msg)
    end

    -- 进入游戏逻辑
    local data, err = slot_logic.spin(uid, agent_id, game_id, bet)

    if err then
        return response.error(err.code, err.msg)
    end

    return response.success(data)
end

-- Free Spin
function CMD.play_free_spin(uid, agent_id, game_id, free_spin_id, request_id)

    -- 游戏配置
    local cfg = skynet.call(
        config_mgr,
        "lua",
        "get_game",
        game_id
    )

    if not cfg then
        return response.error(-2002, "game not found")
    end

    if cfg.status ~= 1 then
        return response.error(-2008, "game disabled")
    end

    if cfg.maintenance == 1 then
        return response.error(-2009, cfg.maintenance_msg)
    end

    -- 进入游戏逻辑
    local data, err = slot_logic.play_free_spin(uid, agent_id, game_id, free_spin_id, request_id)

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
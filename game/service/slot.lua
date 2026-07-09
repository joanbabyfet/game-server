local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local slot_logic = require "logic.slot"
local constant = require "common.constant"

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
        return nil, {
            code = constant.ERROR.GAME_NOT_FOUND,
            msg = "game not found",
        }
    end

    if cfg.status ~= 1 then
        return nil, {
            code = constant.ERROR.GAME_DISABLED,
            msg = "game disabled",
        }
    end

    if cfg.maintenance == 1 then
        return nil, {
            code = constant.ERROR.GAME_MAINTENANCE,
            msg = cfg.maintenance_msg,
        }
    end

    -- 进入游戏逻辑
    local data, err = slot_logic.spin(uid, agent_id, game_id, bet)

    if err then
        return nil, err
    end

    return data
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
        return nil, {
            code = constant.ERROR.GAME_NOT_FOUND,
            msg = "game not found",
        }
    end

    if cfg.status ~= 1 then
        return nil, {
            code = constant.ERROR.GAME_DISABLED,
            msg = "game disabled",
        }
    end

    if cfg.maintenance == 1 then
        return nil, {
            code = constant.ERROR.GAME_MAINTENANCE,
            msg = cfg.maintenance_msg,
        }
    end

    -- 进入游戏逻辑
    local data, err = slot_logic.play_free_spin(uid, agent_id, game_id, free_spin_id, request_id)

    if err then
        return nil, err
    end

    return data
end

skynet.start(function()

    skynet.error("[SLOT] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        if not f then
            skynet.error(string.format(
                "[SLOT] unknown cmd=%s source=%08x",
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
    skynet.register(".slot")
end)
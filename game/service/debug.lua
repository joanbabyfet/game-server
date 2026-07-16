local skynet = require "skynet"
require "skynet.manager"
local json = require "json"
local constant = require "common.constant"

-- 开发调试用
local CMD = {}

-- Config
function CMD.version()

    local config_mgr = skynet.localname(".config_mgr")

    return skynet.call(
        config_mgr,
        "lua",
        "version"
    )

end

function CMD.games()

    local config_mgr = skynet.localname(".config_mgr")

    local cfg = skynet.call(
        config_mgr,
        "lua",
        "get_all"
    )

    return json.encode(cfg)
end

function CMD.config(game_id)

    local config_mgr = skynet.localname(".config_mgr")

    local cfg = skynet.call(
        config_mgr,
        "lua",
        "get_game",
        game_id
    )

    return json.encode(cfg)

end

function CMD.reload()

    local config_mgr = skynet.localname(".config_mgr")

    return skynet.call(
        config_mgr,
        "lua",
        "reload"
    )

end

function CMD.reload_game(game_id)

    local config_mgr = skynet.localname(".config_mgr")

    return skynet.call(
        config_mgr,
        "lua",
        "reload_game",
        game_id
    )

end

-- Slot
function CMD.spin(data)

    local slot = skynet.localname(".slot")

    return skynet.call(
        slot,
        "lua",
        "bet",
        data
    )

end

-- Wallet
function CMD.wallet(uid)

    local wallet = skynet.localname(".wallet")

    return skynet.call(
        wallet,
        "lua",
        "info",
        uid
    )

end

-- Jackpot
function CMD.jackpot(game_id)

    local jackpot = skynet.localname(".jackpot")

    return skynet.call(
        jackpot,
        "lua",
        "info",
        game_id
    )

end

-- RTP
function CMD.rtp(game_id)

    local rtp = skynet.localname(".rtp")

    return skynet.call(
        rtp,
        "lua",
        "info",
        game_id
    )

end

-- Dispatch
skynet.start(function()

    skynet.error("[DEBUG] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        if not f then
            skynet.error(string.format(
                "[DEBUG] unknown cmd=%s source=%08x",
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

    skynet.register(".debug")

end)
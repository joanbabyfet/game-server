local skynet = require "skynet"
require "skynet.manager"
local json = require "json"

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

-- Login
function CMD.login(account)

    local login = skynet.queryservice(".login")

    return skynet.call(
        login,
        "lua",
        "login",
        account
    )

end

-- Slot
function CMD.spin(uid, agent_id, game_id, bet)

    local slot = skynet.queryservice(".slot")

    return skynet.call(
        slot,
        "lua",
        "spin",
        uid,
        agent_id,
        game_id,
        bet
    )

end

-- Wallet
function CMD.wallet(uid)

    local wallet = skynet.queryservice(".wallet")

    return skynet.call(
        wallet,
        "lua",
        "info",
        uid
    )

end

-- Jackpot
function CMD.jackpot(game_id)

    local jackpot = skynet.queryservice(".jackpot")

    return skynet.call(
        jackpot,
        "lua",
        "info",
        game_id
    )

end

-- RTP
function CMD.rtp(game_id)

    local rtp = skynet.queryservice(".rtp")

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

        assert(f, "unknown cmd : " .. tostring(cmd))

        skynet.retpack(
            f(...)
        )

    end)

    skynet.register(".debug")

end)
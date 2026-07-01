local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local json = require "json"
local util = require "common.util"
local wallet_logic = require "logic.wallet"
local jackpot_logic = require "logic.jackpot"

-- 自动测试用
local CMD = {}

-- 测试Config
local function test_config()

    local config_mgr = skynet.localname(".config_mgr")

    local version = skynet.call(config_mgr, "lua", "version")

    skynet.error("[TEST][CONFIG] version =", version)

    local cfg = skynet.call(config_mgr, "lua", "get_game", 1)

    assert(cfg, "game config not found")

    skynet.error("[TEST][CONFIG] game =")
    skynet.error(json.encode(cfg))

    local paytable = skynet.call(
        config_mgr,
        "lua",
        "get",
        1,
        "paytable"
    )

    assert(paytable, "paytable not found")

    skynet.error("[TEST][CONFIG] paytable =")
    skynet.error(json.encode(paytable))

end

-- 测试Reload
local function test_reload()

    local config_mgr = skynet.localname(".config_mgr")

    skynet.call(config_mgr, "lua", "reload")

    local version = skynet.call(config_mgr, "lua", "version")

    skynet.error("[TEST][CONFIG] reload version =", version)

    -- 重新读取
    local cfg = skynet.call(
        config_mgr,
        "lua",
        "get_game",
        1
    )
    skynet.error(json.encode(cfg))

end

-- 测试Login
local function test_login()

    local login = skynet.localname(".login")
    
    local ret = skynet.call(login, "lua", "login", "chris")

    assert(ret.code == 0, ret.msg)

    skynet.error("[TEST][LOGIN] uid =", ret.data.uid)

    return ret.data.uid

end

-- 测试Spin
local function test_spin(uid, game_id, bet, count)

    -- 下注默认 10 USD
    bet = bet or 1000
    count = count or 1

    local slot = skynet.localname(".slot")

    local total_win = 0

    for i = 1, count do
        local ret = skynet.call(
            slot,
            "lua",
            "spin",
            uid,
            game_id,
            bet
        )

        assert(ret.code == 0, ret.msg)

        total_win = total_win + ret.data.win_amount

        skynet.error(string.format(
            "[TEST][SPIN] %d/%d order=%s win=%.2f balance=%.2f",
            i,
            count,
            ret.data.order_no,
            ret.data.win_amount,
            ret.data.balance
        ))
    end

    skynet.error(string.format(
        "[TEST][SPIN] total=%d total_win=%.2f",
        count,
        total_win
    ))
end

-- 测试Wallet
local function test_wallet(uid)

    local wallet, err = wallet_logic.info(uid)

    assert(wallet, err and err.msg)

    skynet.error(
        "[TEST][WALLET] balance =",
        util.to_amount(wallet.balance)
    )

end

-- 测试Jackpot
local function test_jackpot(game_id)

    local pool, err = jackpot_logic.pool(game_id)

    assert(pool, err and err.msg)

    skynet.error(
        string.format(
            "[TEST][JACKPOT] mini=%d minor=%d major=%d grand=%d",
            pool.mini,
            pool.minor,
            pool.major,
            pool.grand
        )
    )

end

-- 测试RTP
local function test_rtp()

    -- TODO

    skynet.error("[TEST][RTP] skip")

end

-- Run
function CMD.run()

    local game_id = 1

    test_config()

    test_reload()

    local uid = test_login()

    -- 连续测试100次 Spin
    test_spin(uid, game_id, 10, 1000)

    test_wallet(uid)

    test_jackpot(game_id)

    test_rtp()

    skynet.error("[TEST] ALL PASS")

    -- skynet.exit()
    return true
end

skynet.start(function()

    skynet.error("[TEST] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        assert(f, "unknown cmd : " .. tostring(cmd))
        
        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".test")
end)
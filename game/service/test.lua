local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local json = require "json"

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
local function test_spin(uid)

    local slot = skynet.localname(".slot")
    
    local ret = skynet.call(
        slot,
        "lua",
        "spin",
        uid,
        1,
        10
    )

    assert(ret.code == 0, ret.msg)

    skynet.error("[TEST][SPIN] success")
    skynet.error("[TEST][SPIN] order_no =", ret.data.order_no)
    skynet.error("[TEST][SPIN] win_amount =", ret.data.win_amount)
    skynet.error("[TEST][SPIN] balance =", ret.data.balance)

end

-- 测试Wallet
local function test_wallet()

    -- TODO

    skynet.error("[TEST][WALLET] skip")

end

-- 测试Jackpot
local function test_jackpot()

    -- TODO

    skynet.error("[TEST][JACKPOT] skip")

end

-- 测试RTP
local function test_rtp()

    -- TODO

    skynet.error("[TEST][RTP] skip")

end

-- Run
function CMD.run()

    test_config()

    test_reload()

    local uid = test_login()

    test_spin(uid)

    test_wallet()

    test_jackpot()

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
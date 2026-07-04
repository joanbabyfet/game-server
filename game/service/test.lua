local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local json = require "json"
local util = require "common.util"
local wallet_logic = require "logic.wallet"
local jackpot_logic = require "logic.jackpot"
local rtp_logic = require "logic.rtp"

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

    skynet.error("[TEST][LOGIN] uid =", ret.data)

    return ret.data

end

-- 测试 Spin + Free Spin
local function test_spin(uid, agent_id, game_id, bet, count)

    -- 下注默认 10 USD
    bet = bet or 1000
    count = count or 1

    local slot = skynet.localname(".slot")

    local total_win = 0

    for i = 1, count do
        -- 普通 Spin
        local request_id = util.uuid()
        local ret = skynet.call(
            slot,
            "lua",
            "spin",
            uid,
            agent_id,
            game_id,
            bet,
            request_id
        )

        assert(ret.code == 0, ret.msg)

        total_win = total_win + ret.data.win_amount

        skynet.error(string.format(
            "[TEST][SPIN] %d/%d request=%s order=%s win=%.2f balance=%.2f",
            i,
            count,
            request_id,
            ret.data.order_no,
            ret.data.win_amount,
            ret.data.balance
        ))

        -- Trigger Free Spin 
        local fs = ret.data.free_spin
        if fs and fs.trigger then
            -- 写入日志
            skynet.error(string.format(
                "[TEST][FREE_SPIN] trigger id=%s total=%d",
                fs.free_spin_id,
                fs.total_count
            ))
            
            local free_spin_id = fs.free_spin_id
            while fs.remain_count > 0 do
                local free_request_id = util.uuid()
                local free_ret = skynet.call(
                    slot,
                    "lua",
                    "play_free_spin",
                    uid,
                    free_spin_id,   -- 永远用第一次的 ID
                    free_request_id
                )

                assert(free_ret.code == 0, free_ret.msg)

                total_win = total_win + free_ret.data.win_amount

                fs = free_ret.data.free_spin

                skynet.error(string.format(
                    "[TEST][FREE_SPIN] request=%s remain=%d win=%.2f balance=%.2f",
                    free_request_id,
                    fs.remain_count,
                    free_ret.data.win_amount,
                    free_ret.data.balance
                ))
            end

            skynet.error("[TEST][FREE_SPIN] finished")
        end
    end

    skynet.error(string.format(
        "[TEST][TOTAL] spin=%d total_win=%.2f",
        count,
        total_win
    ))

    -- 打印 RTP
    local stat = rtp_logic.info(game_id)

    local rtp = 0
    if stat.bet > 0 then
        rtp = stat.win / stat.bet * 100
    end

    skynet.error(string.format(
        "[RTP] spin=%d bet=%.2f win=%.2f rtp=%.4f%%",
        stat.spin,
        util.to_amount(stat.bet),
        util.to_amount(stat.win),
        rtp
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

    local user = test_login()

    -- 连续测试100次 Spin
    test_spin(user.uid, user.agent_id, game_id, 10, 10000)

    test_wallet(user.uid)

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
local skynet = require "skynet"
local redis = require "common.redis"
local rtp_stat_model = require "model.rtp_stat"

local DIRTY_KEY = "rtp:dirty"

local function cache_key(game_id)
    return "rtp:" .. game_id
end

local function sync_game(game_id)

    local stat = redis.hgetall_map(cache_key(game_id))

    if not stat or next(stat) == nil then
        return
    end

    local ok = rtp_stat_model.update({
        game_id = tonumber(game_id),
        total_spin = tonumber(stat.spin) or 0,
        total_bet = tonumber(stat.bet) or 0,
        total_win = tonumber(stat.win) or 0,
    })

    if ok then
        redis.srem(DIRTY_KEY, game_id)
    else
        skynet.error(string.format(
            "[rtp_sync] update mysql failed game=%s",
            tostring(game_id)
        ))
    end
end

local function sync_all()

    local games = redis.smembers(DIRTY_KEY)

    if not games or #games == 0 then
        return
    end

    for _, game_id in ipairs(games) do
        local ok, err = pcall(
            sync_game,
            game_id
        )

        if not ok then
            skynet.error(string.format(
                "[rtp_sync] %s",
                tostring(err)
            ))
        end
    end
end

skynet.start(function()
    skynet.error("[rtp_sync] started")

    skynet.fork(function()
        while true do
            -- 没有 pcall, Lua 会直接抛异常, 整个 while 所在的协程立即结束, 永远不会再同步
            -- sync_all()

            -- 发生异常，也不会导致整个同步协程退出
            local ok, err = pcall(sync_all)

            if not ok then
                skynet.error(string.format(
                    "[rtp_sync] %s",
                    tostring(err)
                ))
            end

            -- 每3秒同步一次
            skynet.sleep(300)
        end
    end)
end)
local skynet = require "skynet"
local redis = require "common.redis"
local jackpot_pool_model = require "model.jackpot_pool"

local DIRTY_KEY = "jackpot:dirty"

local function cache_key(game_id)
    return "jackpot:" .. game_id
end

-- 同步单个奖池
local function sync_pool(game_id)

    local pool = redis.hgetall(cache_key(game_id))

    if not pool or next(pool) == nil then
        return
    end

    local ok = jackpot_pool_model.update({
        game_id = tonumber(game_id),
        mini = tonumber(pool.mini) or 0,
        minor = tonumber(pool.minor) or 0,
        major = tonumber(pool.major) or 0,
        grand = tonumber(pool.grand) or 0,
    })

    if ok then
        redis.srem(DIRTY_KEY, game_id)
    else
        skynet.error(string.format(
            "[jackpot_sync] update mysql failed game_id=%s",
            tostring(game_id)
        ))
    end
end

-- 同步所有脏数据
local function sync_all()
    local games = redis.smembers(DIRTY_KEY)

    if not games then
        return
    end

    for _, game_id in ipairs(games) do
        local ok, err = pcall(sync_pool, game_id)

        if not ok then
            skynet.error(string.format(
                "[jackpot_sync] sync game=%s err=%s",
                tostring(game_id),
                tostring(err)
            ))
        end
    end
end

-- Redis 主存 + MySQL 定时同步 (定时把 Redis 同步到 MySQL)
skynet.start(function()
    skynet.error("[jackpot_sync] started")

    -- 启动一个后台 coroutine (worker1), 一个永远运行的 Service + 一个后台协程(worker)
    skynet.fork(function()
        while true do
            local ok, err = pcall(sync_all)

            if not ok then
                skynet.error(string.format(
                    "[jackpot_sync] %s",
                    tostring(err)
                ))
            end
            
            -- 每5秒同步一次
            skynet.sleep(500)
        end
    end)
end)
local skynet = require "skynet"
local redis = require "skynet.db.redis"
local conf = require "config.redis"

local M = {}

local db

function M.connect()
    -- 单例
    if db then
        return db
    end

    skynet.error(string.format(
        "[REDIS] connecting to %s:%s db=%s",
        conf.host,
        conf.port,
        conf.db or 0
    ))

    local start = skynet.now()

    -- redis挂了/service直接崩
    local ok, ret = pcall(redis.connect, {
        host = conf.host,
        port = conf.port,
        db = conf.db,
        auth = conf.auth,
    })

    local cost = (skynet.now() - start) * 10 -- ms

    if not ok then
        skynet.error(string.format(
            "[REDIS] connect exception, cost=%dms, err=%s",
            cost,
            tostring(ret)
        ))
        return nil
    end

    db = ret

    if not db then
        skynet.error(string.format(
            "[REDIS] connect failed, cost=%dms",
            cost
        ))
        return nil
    end

    skynet.error(string.format(
        "[REDIS] connect success, cost=%dms",
        cost
    ))

    return db
end

local function command(cmd, ...)

    local conn = M.connect()

    if not conn then
        return nil
    end

    -- 防止调用不存在的 Redis 命令
    local func = conn[cmd]
    if not func then
        skynet.error(string.format(
            "[REDIS ERROR] unknown command=%s",
            cmd
        ))
        return nil
    end

    local ok, ret = pcall(
        func,
        conn,
        ...
    )

    if not ok then
        -- 重连时打印日志
        skynet.error(string.format(
            "[REDIS ERROR] cmd=%s err=%s",
            cmd,
            tostring(ret)
        ))

        -- 下次自动重连
        db = nil

        return nil
    end

    return ret
end

-- 这里用 Lua 的 __index 元方法动态代理所有 Redis 命令
setmetatable(M, {
    __index = function(_, cmd)

        return function(...)
            return command(cmd, ...)
        end

    end
})

return M
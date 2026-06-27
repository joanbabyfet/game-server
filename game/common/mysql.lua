local mysql = require "skynet.db.mysql"
local conf = require "config.mysql"
local skynet = require "skynet"

local M = {}

local db

-- 连接
function M.connect()
    -- 单例
    if db then
        return db
    end

    skynet.error(string.format(
        "[MYSQL] connecting to %s:%s/%s",
        conf.host,
        conf.port,
        conf.database
    ))

    db = mysql.connect({
        host = conf.host,
        port = conf.port,
        database = conf.database,
        user = conf.user,
        password = conf.password,
        max_packet_size = conf.max_packet_size,
    })

    if not db then
        skynet.error("[MYSQL] connect failed")
        return nil
    end

    skynet.error("[MYSQL] connect success")

    return db
end

-- 增删改查
function M.query(sql)

    local conn = M.connect()

    if not conn then
        return nil
    end

    -- 保护调用, 不要在每个 Model 里写pcall, 执行成功 ok=true 异常 ok=false
    local ok, ret = pcall(conn.query, conn, sql)

    if not ok then
        skynet.error("[MYSQL ERROR]", ret)
        skynet.error(sql)
        return nil
    end

    return ret
end

-- 获取单条
function M.get_one(sql)
    
    local ret = M.query(sql)

    return ret and ret[1]
end

-- 开启事务
function M.begin()
    return M.query("BEGIN")
end

-- 提交事务
function M.commit()
    return M.query("COMMIT")
end

-- 回滚事务
function M.rollback()
    return M.query("ROLLBACK")
end

return M
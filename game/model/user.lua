local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

-- 创建一个空 Table, M为模块
local M = {}

-- 获取用户信息, 给 Table 增加函数
function M.get(uid)
    local sql = string.format([[
        SELECT *
        FROM user
        WHERE uid = %d
        LIMIT 1
    ]], uid)

    return db.get_one(sql)
end

-- 根据用户名获取用户信息
function M.get_by_username(username)
    local sql = string.format(
        "SELECT * FROM user WHERE username = %s LIMIT 1",
        mysql.quote_sql_str(username)
    )

    return db.get_one(sql)
end

-- 创建用户
function M.create(username, nickname)
    local sql = string.format([[
        INSERT INTO user(
            username,
            nickname,
            status,
            create_time
        )
        VALUES(
            %s,
            %s,
            1,
            %d
        )
    ]],
        mysql.quote_sql_str(username),
        mysql.quote_sql_str(nickname),
        os.time()
    )
    
    local ret = db.query(sql)
    if not ret then
        return nil
    end

    return ret.insert_id
end

return M
local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

-- 创建一个空 Table, M为模块
local M = {}

local TABLE = "user"

-- 获取用户信息, 给 Table 增加函数
-- function M.get(uid)

--     local sql = string.format([[
--         SELECT *
--         FROM %s
--         WHERE uid = %d
--         LIMIT 1
--     ]],
--         TABLE,
--         uid
--     )

--     return db.get_one(sql)
-- end

-- 根据用户名获取用户信息
function M.get_by_username(username)

    local sql = string.format(
        "SELECT * FROM %s WHERE username = %s LIMIT 1",
        TABLE,
        mysql.quote_sql_str(username)
    )

    return db.get_one(sql)
end

-- 创建用户
-- function M.create(username, nickname)

--     local sql = string.format([[
--         INSERT INTO %s(
--             username,
--             nickname,
--             status,
--             create_time
--         )
--         VALUES(
--             %s,
--             %s,
--             1,
--             %d
--         )
--     ]],
--         TABLE,
--         mysql.quote_sql_str(username),
--         mysql.quote_sql_str(nickname),
--         os.time()
--     )

--     local ret = db.query(sql)
--     if not ret then
--         return nil
--     end

--     return ret.insert_id
-- end

-- 更新最后登录时间
-- function M.update_last_login_time(uid)

--     local sql = string.format([[
--         UPDATE %s
--         SET
--             last_login_time = %d
--         WHERE uid = %d
--     ]],
--         TABLE,
--         os.time(),
--         uid
--     )

--     return db.query(sql)
-- end

return M
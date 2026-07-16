local db = require "common.mysql"

local M = {}

local TABLE = "wallet"

-- 获取钱包余额
function M.get(uid)

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE uid = %d
        LIMIT 1
    ]],
        TABLE,
        uid
    )

    return db.get_one(sql)
end

-- 创建用户钱包, 测试先给余额 10000
-- function M.create(uid, agent_id, balance)

--     local sql = string.format([[
--         INSERT INTO %s(
--             uid,
--             agent_id,
--             balance,
--             freeze_balance,
--             create_time
--         )
--         VALUES(
--             %d,
--             %d,
--             %d,
--             0,
--             %d
--         )
--     ]],
--         TABLE,
--         uid,
--         agent_id,
--         balance,
--         os.time()
--     )

--     return db.query(sql)
-- end

-- 充值
function M.add(uid, amount)

    local sql = string.format([[
        UPDATE %s
        SET
            balance = balance + %d,
            update_time = %d
        WHERE uid = %d
    ]],
        TABLE,
        amount,
        os.time(),
        uid
    )

    return db.query(sql)
end

-- 扣款
function M.sub(uid, amount)

    -- 防止并发超扣问题
    local sql = string.format([[
        UPDATE %s
        SET
            balance = balance - %d,
            update_time = %d
        WHERE uid = %d AND balance >= %d
    ]],
        TABLE,
        amount,
        os.time(),
        uid,
        amount
    )

    local ret = db.query(sql)
    if not ret then
        return false
    end

    return ret.affected_rows == 1
end

-- 是否存在
function M.exists(uid)

    local sql = string.format([[
        SELECT 1
        FROM %s
        WHERE uid=%d
        LIMIT 1
    ]],
        TABLE,
        uid
    )

    local ret = db.query(sql)

    return ret and #ret > 0
end

return M
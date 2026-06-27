local db = require "common.mysql"

local M = {}

-- 获取钱包余额
function M.get(uid)
    local sql = string.format([[
        SELECT *
        FROM wallet
        WHERE uid = %d
        LIMIT 1
    ]], uid)

    return db.get_one(sql)
end

-- 创建用户钱包, 测试先给余额 10000
function M.create(uid, balance)
    local sql = string.format([[
        INSERT INTO wallet(
            uid,
            balance,
            freeze_balance,
            create_time
        )
        VALUES(
            %d,
            %d,
            0,
            %d
        )
    ]],
        uid,
        balance,
        os.time()
    )

    return db.query(sql)
end

-- 充值
function M.add(uid, amount)
    local sql = string.format([[
        UPDATE wallet
        SET
            balance = balance + %d,
            update_time = %d
        WHERE uid = %d
    ]],
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
        UPDATE wallet
        SET
            balance = balance - %d,
            update_time = %d
        WHERE uid = %d AND balance >= %d
    ]],
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

return M
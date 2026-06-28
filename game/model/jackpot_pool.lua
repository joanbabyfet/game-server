local db = require "common.mysql"

local M = {}

-- 获取某游戏奖池信息
function M.get(game_id)
    local sql = string.format([[
        SELECT *
        FROM jackpot_pool
        WHERE game_id = %d
        LIMIT 1
    ]], game_id)

    return db.get_one(sql)
end

-- 更新某游戏jackpot奖池金额
function M.update(data)

    local now = os.time()

    local sql = string.format([[
        INSERT INTO jackpot_pool(
            game_id,
            mini,
            minor,
            major,
            grand,
            create_time,
            update_time
        )
        VALUES(
            %d,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d
        )
        ON DUPLICATE KEY UPDATE

        mini = VALUES(mini),

        minor = VALUES(minor),

        major = VALUES(major),

        grand = VALUES(grand),

        update_time = VALUES(update_time)
    ]],
        data.game_id,
        data.mini,
        data.minor,
        data.major,
        data.grand,
        now,
        now
    )

    return db.query(sql)
end

-- 重置某游戏jackpot奖池金额
-- function M.reset(game_id, field, amount)
--     local sql = string.format([[
--         UPDATE jackpot_pool
--         SET
--             %s = %d,
--             update_time = %d
--         WHERE game_id = %d
--     ]],
--         field,
--         amount,
--         os.time(),
--         game_id
--     )

--     return db.query(sql)
-- end

return M
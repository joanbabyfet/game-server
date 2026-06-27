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

-- 增加某游戏jackpot奖池金额
function M.add(game_id, field, amount)
    local sql = string.format([[
        UPDATE jackpot_pool
        SET
            %s = %s + %d,
            update_time = %d
        WHERE game_id = %d
    ]],
        field,
        field,
        amount,
        os.time(),
        game_id
    )

    return db.query(sql)
end

-- 重置某游戏jackpot奖池金额
function M.reset(game_id, field, amount)
    local sql = string.format([[
        UPDATE jackpot_pool
        SET
            %s = %d,
            update_time = %d
        WHERE game_id = %d
    ]],
        field,
        amount,
        os.time(),
        game_id
    )

    return db.query(sql)
end

return M
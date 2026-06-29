local db = require "common.mysql"
local mysql = require "skynet.db.mysql"
local json = require "json"

local M = {}

-- 创建注单
function M.create(data)

    local sql = string.format([[
        INSERT INTO `order`(
            request_id,
            order_no,
            round_id,
            uid,
            game_id,
            bet_amount,
            original_win,
            win_amount,
            profit,
            balance_before,
            balance_after,
            reels,
            win_lines,
            is_free_spin,
            status,
            settle_time,
            create_time
        )
        VALUES(
            %s,
            %s,
            %s,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d,
            %s,
            %s,
            %d,
            %d,
            %d,
            %d
        )
    ]],
        mysql.quote_sql_str(data.request_id),
        mysql.quote_sql_str(data.order_no),
        mysql.quote_sql_str(data.round_id),
        data.uid,
        data.game_id,
        data.bet_amount,
        data.original_win,
        data.win_amount,
        data.profit,
        data.balance_before,
        data.balance_after,
        mysql.quote_sql_str(json.encode(data.reels)),
        mysql.quote_sql_str(json.encode(data.win_lines)),
        data.is_free_spin or 0,
        data.status,
        data.settle_time,
        data.create_time
    )

    return db.query(sql)
end

-- 根据幂等请求ID获取订单信息
function M.get_by_request_id(request_id)

    local sql = string.format([[
        SELECT *
        FROM `order`
        WHERE request_id='%s'
        LIMIT 1
    ]], mysql.quote_sql_str(request_id))

    return db.get_one(sql)
end

return M
local db = require "common.mysql"
local mysql = require "skynet.db.mysql"
local json = require "json"

local M = {}

local TABLE = "game_order"

-- 注单状态
M.STATUS = {
    PROCESSING = 0, -- 处理中
    SETTLED    = 1, -- 已结算
    ROLLBACK   = 2, -- 已回滚
}

-- 创建注单
function M.create(data)

    local sql = string.format([[
        INSERT INTO `%s`(
            request_id,
            order_no,
            round_id,
            uid,
            agent_id,
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
            free_spin_id,
            free_spin_index,
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
            %d,
            %s,
            %s,
            %d,
            %s,
            %d,
            %d,
            %d,
            %d
        )
    ]],
        TABLE,
        mysql.quote_sql_str(data.request_id),
        mysql.quote_sql_str(data.order_no),
        mysql.quote_sql_str(data.round_id),
        data.uid,
        data.agent_id,
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
        mysql.quote_sql_str(data.free_spin_id or ""),
        data.free_spin_index or 0,
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
        FROM `%s`
        WHERE request_id = %s
        LIMIT 1
    ]],
        TABLE,
        mysql.quote_sql_str(request_id)
    )

    return db.get_one(sql)
end

-- 根据订单号获取订单
function M.get_by_order_no(order_no)

    local sql = string.format([[
        SELECT *
        FROM `%s`
        WHERE order_no = %s
        LIMIT 1
    ]],
        TABLE,
        mysql.quote_sql_str(order_no)
    )

    return db.get_one(sql)
end

-- 更新订单为已回滚 (只有已结算才能回滚)
function M.rollback(order_no, reason)

    local sql = string.format([[
        UPDATE `%s`
        SET
            status = %d,
            rollback_reason = %s,
            rollback_time = %d
        WHERE
            order_no = %s
        AND
            status = %d
        LIMIT 1
    ]],
        TABLE,
        M.STATUS.ROLLBACK,
        mysql.quote_sql_str(reason),
        os.time(),
        mysql.quote_sql_str(order_no),
        M.STATUS.SETTLED
    )

    return db.query(sql)
end

return M
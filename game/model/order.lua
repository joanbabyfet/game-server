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
            balance_before,
            balance_after,
            currency,
            reels,
            win_lines,
            is_free_spin,
            status,
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
            %s,
            %s,
            %s,
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
        data.balance_before or 0,
        data.balance_after or 0,
        mysql.quote_sql_str(data.currency or ""),
        mysql.quote_sql_str(json.encode(data.reels or {})),
        mysql.quote_sql_str(json.encode(data.win_lines or {})),
        data.is_free_spin or 0,
        data.status,
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

-- 更新订单状态 (私有函数)
local function update_status(order_no, from_status, to_status, reason)

    reason = reason or ""

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
        to_status,
        mysql.quote_sql_str(reason),
        os.time(),
        mysql.quote_sql_str(order_no),
        from_status
    )

    return db.query(sql)
end

-- 已结算订单回滚（SETTLED -> ROLLBACK）
function M.finish_rollback(order_no, reason)

    return update_status(
        order_no,
        M.STATUS.SETTLED,
        M.STATUS.ROLLBACK,
        reason
    )
end

-- 未结算订单取消（PROCESSING -> ROLLBACK）
function M.cancel(order_no, reason)

    return update_status(
        order_no,
        M.STATUS.PROCESSING,
        M.STATUS.ROLLBACK,
        reason
    )
end

-- 更新注单(结算完成)
function M.update(data)

    local sql = string.format([[
        UPDATE `%s`
        SET
            original_win = %d,
            win_amount = %d,
            profit = %d,
            balance_after = %d,
            reels = %s,
            win_lines = %s,
            risk_hit = %d,
            risk_reason = %s,
            free_spin_id = %s,
            free_spin_index = %d,
            status = %d,
            settle_time = %d
        WHERE
            order_no = %s AND status = %d
        LIMIT 1
    ]],
        TABLE,
        data.original_win,
        data.win_amount,
        data.profit,
        data.balance_after,
        mysql.quote_sql_str(json.encode(data.reels)),
        mysql.quote_sql_str(json.encode(data.win_lines)),
        data.risk_hit and 1 or 0,
        mysql.quote_sql_str(data.risk_reason or ""),
        mysql.quote_sql_str(data.free_spin_id or ""),
        data.free_spin_index or 0,
        data.status,
        data.settle_time,
        mysql.quote_sql_str(data.order_no),
        M.STATUS.PROCESSING -- 避免 已经 SETTLED 的订单再次被更新
    )

    return db.query(sql)
end

return M
local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

local M = {}

local TABLE = "free_spin"

-- Free Spin 状态
M.STATUS = {
    RUNNING = 0, -- 进行中
    FINISHED = 1, -- 已完成
    CANCELED = 2, -- 已取消
}

-- 创建 Free Spin 批次
function M.create(data)

    local sql = string.format([[
        INSERT INTO %s(
            free_spin_id,
            uid,
            agent_id,
            game_id,
            trigger_order_no,
            bet_amount,
            total_count,
            remain_count,
            total_win_amount,
            status,
            create_time,
            finish_time
        )
        VALUES(
            %s,
            %d,
            %d,
            %d,
            %s,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d
        )
    ]],
        TABLE,
        mysql.quote_sql_str(data.free_spin_id),
        data.uid,
        data.agent_id,
        data.game_id,
        mysql.quote_sql_str(data.trigger_order_no),
        data.bet_amount,
        data.total_count,
        data.remain_count,
        data.total_win_amount or 0,
        data.status or 0,
        data.create_time or os.time(),
        data.finish_time or 0
    )

    return db.query(sql)
end

-- 根据 Free Spin ID 查询
function M.get(free_spin_id)

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE free_spin_id = %s
        LIMIT 1
    ]],
        TABLE,
        mysql.quote_sql_str(free_spin_id)
    )

    return db.get_one(sql)
end

-- 根据触发订单查询 Free Spin
function M.get_by_trigger_order_no(order_no)

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE trigger_order_no = %s
        LIMIT 1
    ]],
        TABLE,
        mysql.quote_sql_str(order_no)
    )

    return db.get_one(sql)
end

-- 查询玩家进行中的 Free Spin
function M.get_running(uid, game_id)

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE uid = %d
        AND game_id = %d
        AND status = 0
        ORDER BY id DESC
        LIMIT 1
    ]],
        TABLE,
        uid,
        game_id
    )

    return db.get_one(sql)
end

-- 消耗一次 Free Spin
function M.decrease_remain(free_spin_id, win_amount)

    local sql = string.format([[
        UPDATE %s
        SET 
            remain_count = remain_count - 1,
            total_win_amount = total_win_amount + %d
        WHERE free_spin_id = %s
        AND remain_count > 0
    ]],
        TABLE,
        win_amount,
        mysql.quote_sql_str(free_spin_id)
    )

    local ret = db.query(sql)

    if not ret or ret.affected_rows ~= 1 then
        return nil
    end

    return true
end

-- Free Spin 完成
function M.finish(free_spin_id)

    local now = os.time()

    local sql = string.format([[
        UPDATE %s
        SET
            remain_count = 0,
            status = %d,
            finish_time = %d
        WHERE free_spin_id = %s
    ]],
        TABLE,
        M.STATUS.FINISHED,
        now,
        mysql.quote_sql_str(free_spin_id)
    )

    return db.query(sql)
end

return M
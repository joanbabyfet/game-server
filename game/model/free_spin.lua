local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

local M = {}

------------------------------------------------
-- 创建 Free Spin 批次
------------------------------------------------
function M.create(data)

    local sql = string.format([[
        INSERT INTO free_spin(
            free_spin_id,
            uid,
            game_id,
            trigger_order_no,
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
            %s,
            %d,
            %d,
            %d,
            %d,
            %d,
            %d
        )
    ]],
        mysql.quote_sql_str(data.free_spin_id),
        data.uid,
        data.game_id,
        mysql.quote_sql_str(data.trigger_order_no),
        data.total_count,
        data.remain_count,
        data.total_win_amount or 0,
        data.status or 0,
        data.create_time or os.time(),
        data.finish_time or 0
    )

    return db.query(sql)

end

return M
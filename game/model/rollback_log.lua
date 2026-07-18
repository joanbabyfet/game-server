local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

local M = {}

local TABLE = "rollback_log"

-- 回滚类型
M.TYPE = {
    PROVIDER = 1,
    ADMIN    = 2,
    RETRY    = 3,
    CANCEL   = 4, --建单成功，但还没结算就取消
}

-- 回滚状态
M.STATUS = {
    SUCCESS = 1,
    FAIL    = 2,
}

-- 创建回滚记录
function M.create(data)

    local sql = string.format([[
        INSERT INTO %s(
            rollback_type,
            rollback_no,
            order_no,
            round_id,
            request_id,
            agent_id,
            uid,
            game_id,
            amount,
            reason,
            status,
            create_time
        )
        VALUES(
            %d,
            %s,
            %s,
            %s,
            %s,
            %d,
            %d,
            %d,
            %d,
            %s,
            %d,
            %d
        )
    ]],
        TABLE,
        data.rollback_type,
        mysql.quote_sql_str(data.rollback_no),
        mysql.quote_sql_str(data.order_no),
        mysql.quote_sql_str(data.round_id),
        mysql.quote_sql_str(data.request_id),
        data.agent_id,
        data.uid,
        data.game_id,
        data.amount,
        mysql.quote_sql_str(data.reason or ""),
        data.status,
        os.time()
    )

    return db.query(sql)
end

return M
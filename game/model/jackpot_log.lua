local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

local M = {}

-- 创建Jackpot中奖记录
function M.create(data)
    local sql = string.format([[
        INSERT INTO jackpot_log(
            uid,
            game_id,
            jackpot_type,
            amount,
            create_time
        )
        VALUES(
            %d,
            %d,
            %s,
            %d,
            %d
        )
    ]],
        data.uid,
        data.game_id,
        mysql.quote_sql_str(data.jackpot_type),
        data.amount,
        os.time()
    )

    return db.query(sql)
end

return M
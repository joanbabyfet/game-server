local db = require "common.mysql"
local mysql = require "skynet.db.mysql"

local M = {}

local TABLE = "wallet_log"

-- 钱包流水类型
M.TYPE = {
    BET      = "BET",
    WIN      = "WIN",
    BONUS    = "BONUS",
    JACKPOT  = "JACKPOT",
    DEPOSIT  = "DEPOSIT",
    WITHDRAW = "WITHDRAW",
    ROLLBACK = "ROLLBACK",
}

-- 写入钱包流水
function M.create(data)

    local sql = string.format([[
        INSERT INTO %s(
            uid,
            agent_id,
            game_id,
            type,
            amount,
            balance_before,
            balance_after,
            ref_order_no,
            create_time
        )
        VALUES(
            %d,
            %d,
            %d,
            %s,
            %d,
            %d,
            %d,
            %s,
            %d
        )
    ]],
        TABLE,
        data.uid or 0,
        data.agent_id or 0,
        data.game_id or 0,
        mysql.quote_sql_str(data.type),
        data.amount or 0,
        data.balance_before or 0,
        data.balance_after or 0,
        mysql.quote_sql_str(data.ref_order_no or ""),
        os.time()
    )

    return db.query(sql)

end

return M
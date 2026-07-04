local db = require "common.mysql"

local M = {}

local TABLE = "game"

-- 游戏状态
M.STATUS = {
    OFFLINE = 0,
    ONLINE  = 1,
}

-- 获取游戏信息
function M.get(game_id)

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE id = %d
        LIMIT 1
    ]],
        TABLE,
        game_id
    )

    return db.get_one(sql)
end

return M
local db = require "common.mysql"

local M = {}

local TABLE = "game_config"

function M.get_all()

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE status = 1
        ORDER BY game_id,id
    ]],
        TABLE
    )

    return db.query(sql)

end

function M.get_by_game(game_id)

    local sql = string.format([[
        SELECT *
        FROM %s
        WHERE game_id = %d
        AND status = 1
        ORDER BY id
    ]],
        TABLE,
        game_id
    )

    return db.query(sql)
end

return M
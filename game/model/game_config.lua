local db = require "common.mysql"

local M = {}

function M.get_all()

    local sql = [[
        SELECT *
        FROM game_config
        WHERE status = 1
        ORDER BY game_id,id
    ]]

    return db.query(sql)

end

function M.get_by_game(game_id)

    local sql = string.format([[
        SELECT *
        FROM game_config
        WHERE game_id = %d
        AND status = 1
        ORDER BY id
    ]],
        game_id
    )

    return db.query(sql)
end

return M
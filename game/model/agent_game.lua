local db = require "common.mysql"

local M = {}

-- 获取 Agent 游戏配置 (如果代理把某个游戏关闭, 获取不到数据)
function M.get(agent_id, game_id)

    local sql = string.format([[
        SELECT
            *
        FROM agent_game
        WHERE agent_id=%d
        AND game_id=%d
        AND status=1
        LIMIT 1
    ]],
        agent_id,
        game_id
    )

    return db.get_one(sql)
end

return M
local db = require "common.mysql"

local M = {}

function M.update(data)

    local now = os.time()

    local sql = string.format([[
        INSERT INTO rtp_stat(
            game_id,
            total_spin,
            total_bet,
            total_win,
            create_time,
            update_time
        )
        VALUES(
            %d,
            %d,
            %d,
            %d,
            %d,
            %d
        )
        ON DUPLICATE KEY UPDATE

        total_spin = VALUES(total_spin),

        total_bet = VALUES(total_bet),

        total_win = VALUES(total_win),

        update_time = VALUES(update_time)
    ]],
        data.game_id,
        data.total_spin,
        data.total_bet,
        data.total_win,
        now,
        now
    )

    return db.query(sql)
end

return M
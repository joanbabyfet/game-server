local skynet = require "skynet"

local M = {}

-- 自定义开始时间
local EPOCH = 1704067200000 -- 2024-01-01 00:00:00

-- 机器ID (0~1023)
local WORKER_ID = 1

local last_ts = 0
local sequence = 0

local function current_ms()
    return math.floor(skynet.time() * 1000)
end

function M.next_id()

    local ts = current_ms()

    if ts < last_ts then
        error("clock moved backwards")
    end

    if ts == last_ts then

        sequence = sequence + 1

        if sequence > 4095 then

            repeat
                ts = current_ms()
            until ts > last_ts

            sequence = 0
        end

    else

        sequence = 0

    end

    last_ts = ts

    local timestamp = ts - EPOCH

    -- 41bit timestamp
    -- 10bit worker_id
    -- 12bit sequence

    local id =
        timestamp * 2^22 +
        WORKER_ID * 2^12 +
        sequence

    return string.format("%.0f", id)
end

return M
local skynet = require "skynet"
require "skynet.manager"
local wallet_logic = require "logic.wallet"
local response = require "common.response"

local CMD = {}

-- 注单回滚
--
-- req = {
--     request_id = "",
--     order_no   = "",
--     uid        = 10001,
--     agent_id   = 1,
-- }
function CMD.rollback(req)

    assert(type(req) == "table", "invalid request")

    local balance, err = wallet_logic.rollback(req)

    if err then
        return response.error(err.code, err.msg)
    end

    return response.success({balance = balance})
end

-- 对外提供服务入口
skynet.start(function()

    skynet.error("[ROLLBACK] start")

    skynet.dispatch("lua", function(_, _, cmd, ...)

        local f = CMD[cmd]
        assert(f, "Unknown cmd: " .. tostring(cmd))

        skynet.retpack(f(...))

    end)

    -- 注册服务
    skynet.register(".rollback")

end)
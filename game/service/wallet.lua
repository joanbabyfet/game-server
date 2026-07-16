local skynet = require "skynet"
require "skynet.manager"
local wallet_logic = require "logic.wallet"
local constant = require "common.constant"
local util = require "common.util"

local CMD = {}

-- 查询余额
function CMD.balance(data)

    local resp, err = wallet_logic.balance(data)

    if err then
        return nil, err
    end

    return resp
end

-- 注单回滚
--
-- req = {
--     request_id = "",
--     order_no   = "",
--     uid        = 10001,
--     agent_id   = 1,
-- }
function CMD.rollback(data)

    local balance, err = wallet_logic.rollback(data)

    if err then
        return nil, err
    end

    return {
        balance = util.to_amount(balance),
    }
end

-- 对外提供服务入口
skynet.start(function()

    skynet.error("[WALLET] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]
        
        if not f then
            skynet.error(string.format(
                "[WALLET] unknown cmd=%s source=%08x",
                tostring(cmd),
                source
            ))

            skynet.retpack(nil, {
                code = constant.ERROR.RPC_UNKNOWN_CMD,
                msg = "unknown cmd",
            })

            return
        end

        skynet.retpack(f(...))

    end)

    -- 注册服务
    skynet.register(".wallet")

end)
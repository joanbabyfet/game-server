local skynet = require "skynet"
local command = require "rpc.command"
local constant = require "common.constant"

local M = {}

local handlers = {

    [command.CMD_AUTHENTICATE] = function(req)
        return skynet.call(".login", "lua", "authenticate", req)
    end,

    [command.CMD_BALANCE] = function(req)
        return skynet.call(".wallet", "lua", "balance", req)
    end,

    [command.CMD_BET] = function(req)
        return skynet.call(".slot", "lua", "bet", req)
    end,

    [command.CMD_ROLLBACK] = function(req)
        return skynet.call(".rollback", "lua", "rollback", req)
    end,

    [command.CMD_PING] = function(req)
        return skynet.call(".system", "lua", "ping", req)
    end,

    [command.CMD_KICK] = function(req)
        return skynet.call(".player_mgr", "lua", "kick", req)
    end,
}

function M.dispatch(packet)

    local handler = handlers[packet.cmd]

    if not handler then
        return nil, {
            code = constant.ERROR.RPC_UNKNOWN_CMD,
            msg = "unknown cmd",
        }
    end

    return handler(packet.data)

end

return M
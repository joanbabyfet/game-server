local command = require "rpc.command"

local M = {

    [command.CMD_LOGIN] = {
        req = "user.LoginReq",
        resp = "user.LoginResp",
    },

    [command.CMD_KICK] = {
        req = "user.KickReq",
        resp = "user.KickResp",
    },

    [command.CMD_SPIN] = {
        req = "slot.BetReq",
        resp = "slot.BetResp",
    },

    [command.CMD_BALANCE] = {
        req = "wallet.BalanceReq",
        resp = "wallet.BalanceResp",
    },

    [command.CMD_ROLLBACK] = {
        req = "wallet.RollbackReq",
        resp = "wallet.RollbackResp",
    },

    [command.CMD_PING] = {
        req = "system.PingReq",
        resp = "system.PingResp",
    },
}

return M
local command = require "rpc.command"

local M = {

    [command.CMD_AUTHENTICATE] = {
        req = "user.AuthenticateReq",
        resp = "user.AuthenticateResp",
    },

    [command.CMD_BALANCE] = {
        req = "wallet.BalanceReq",
        resp = "wallet.BalanceResp",
    },

    [command.CMD_BET] = {
        req = "slot.BetReq",
        resp = "slot.BetResp",
    },

    [command.CMD_ROLLBACK] = {
        req = "wallet.RollbackReq",
        resp = "wallet.RollbackResp",
    },

    [command.CMD_PING] = {
        req = "system.PingReq",
        resp = "system.PingResp",
    },

    [command.CMD_KICK] = {
        req = "user.KickReq",
        resp = "user.KickResp",
    },
}

return M
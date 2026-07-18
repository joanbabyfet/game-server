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
        req = "slot.SpinReq",
        resp = "slot.SpinResp",
    },

    [command.CMD_BALANCE] = {
        req = "wallet.BalanceReq",
        resp = "wallet.BalanceResp",
    },

    [command.CMD_ROLLBACK] = {
        req = "wallet.RollbackReq",
        resp = "wallet.RollbackResp",
    },

    [command.CMD_CANCEL] = {
        req = "wallet.CancelReq",
        resp = "wallet.CancelResp",
    },

    [command.CMD_PING] = {
        req = "system.PingReq",
        resp = "system.PingResp",
    },
}

return M
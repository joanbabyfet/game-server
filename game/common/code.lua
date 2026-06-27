-- 未来可统一管理错误码
local CODE = {
    SUCCESS              = 0,

    USER_NOT_FOUND       = -1001,
    -- 余额不足
    INSUFFICIENT_BALANCE = -1002,
    WALLET_NOT_FOUND     = -1003,

    INVALID_BET          = -2001,
    GAME_NOT_FOUND       = -2002,

    SYSTEM_ERROR         = -9999,
}

return CODE
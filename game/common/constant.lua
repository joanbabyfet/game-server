local M = {}

-- 统一管理错误码
M.ERROR = {
    SUCCESS                     = 0,

    -- 通用
    FAIL                        = -1,
    PARAM_ERROR                 = -2,
    COMMIT_FAILED               = -3,

    -- 用户
    PLAYER_NOT_FOUND              = -1001,
    PLAYER_CREATE_FAILED          = -1002,
    PLAYER_ALREADY_ONLINE         = -1003,
    PLAYER_NOT_ONLINE             = -1004,
    -- 钱包
    INSUFFICIENT_BALANCE        = -1005,
    WALLET_NOT_FOUND            = -1006,
    WALLET_ADD_FAILED           = -1007,
    WALLET_LOG_CREATE_FAILED    = -1008,

    -- 游戏
    INVALID_BET                 = -2001,
    GAME_NOT_FOUND              = -2002,
    GAME_CONFIG_NOT_FOUND       = -2003,
    AGENT_GAME_NOT_FOUND        = -2004,
    SYMBOL_MAP_NOT_FOUND        = -2005,
    BET_TOO_SMALL               = -2006,
    BET_TOO_LARGE               = -2007,
    GAME_DISABLED               = -2008,
    GAME_MAINTENANCE            = -2009,
    AGENT_GAME_DISABLED         = -2010,

    -- Free Spin
    FREE_SPIN_NOT_FOUND         = -3001,
    FREE_SPIN_OWNER_ERROR       = -3002,
    FREE_SPIN_FINISH_FAILED     = -3003,
    FREE_SPIN_UPDATE_FAILED     = -3004,
    FREE_SPIN_CREATE_FAILED     = -3005,
    FREE_SPIN_FINISHED          = -3006,
    FREE_SPIN_GAME_ERROR        = -3007,

    -- Order
    ORDER_NOT_FOUND             = -4001,
    ORDER_STATUS_ERROR          = -4002,
    ORDER_CREATE_FAILED         = -4003,
    ORDER_UPDATE_FAILED         = -4004,
    ORDER_ROLLBACK_FAILED       = -4005,
    ROLLBACK_LOG_CREATE_FAILED  = -4006,

    -- Jackpot
    JACKPOT_ADD_FAILED          = -5001,
    JACKPOT_POOL_NOT_FOUND      = -5002,
    JACKPOT_AMOUNT_INVALID      = -5003,
    JACKPOT_CONFIG_NOT_FOUND    = -5004,
    JACKPOT_RATE_NOT_FOUND      = -5005,
    JACKPOT_BASE_POOL_NOT_FOUND = -5006,
    JACKPOT_TYPE_INVALID        = -5007,
    JACKPOT_LOG_CREATE_FAILED   = -5008,

    -- RPC
    RPC_UNKNOWN_CMD             = -9001,

    -- 系统
    SYSTEM_ERROR                = -9999,
}

return M
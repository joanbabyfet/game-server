local M = {}

-- 订单状态
M.ORDER_STATUS = {
    PROCESSING = 0, -- 处理中
    SETTLED    = 1, -- 已结算
    ROLLBACK   = 2, -- 已回滚
}

-- 钱包流水类型
M.WALLET_LOG_TYPE = {
    BET      = "BET",
    WIN      = "WIN",
    BONUS    = "BONUS",
    JACKPOT  = "JACKPOT",
    DEPOSIT  = "DEPOSIT",
    WITHDRAW = "WITHDRAW",
}

-- 游戏状态
M.GAME_STATUS = {
    OFFLINE = 0,
    ONLINE  = 1,
}

return M
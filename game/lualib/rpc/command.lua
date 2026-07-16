local M = {}

-- 保持该顺序 1000 User 2000 Wallet 3000 Slot 4000 Jackpot

-- User
M.CMD_LOGIN        = 1001
M.CMD_KICK         = 1002

-- Wallet
M.CMD_BALANCE      = 2001
M.CMD_SPIN         = 2002
M.CMD_ROLLBACK     = 2003

M.CMD_PING         = 9999

return M
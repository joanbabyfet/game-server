local snowflake = require "common.snowflake"
local skynet = require "skynet"

local M = {}

-- 只初始化一次随机种子
math.randomseed(os.time() + skynet.now())
math.random()
math.random()
math.random()

-- 金额单位 1 金币 = 100 最小单位
M.MONEY_SCALE = 100

-- UUID v4
function M.uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    return (template:gsub("[xy]", function(c)
        local v
        if c == "x" then
            v = math.random(0, 15)
        else
            v = math.random(8, 11)
        end
        return string.format("%x", v)
    end))
end

-- 生成注单号 (雪花ID)
function M.gen_order_no()
    return "S" .. snowflake.next_id()
end

-- 生成局号 (雪花ID)
function M.gen_round_id()
    return "R" .. snowflake.next_id()
end

-- 生成所属FreeSpin批次ID (雪花ID)
function M.gen_free_spin_id()
    return "FS" .. snowflake.next_id()
end

-- 生成用户id
function M.gen_uid()
    return tostring(snowflake.next_id())
end

-- 金额转最小单位
function M.to_money(value)
    return math.floor(value * M.MONEY_SCALE)
end

-- 最小单位转金额
function M.to_amount(value)
    return value / M.MONEY_SCALE
end

-- 百分比 util.percent(1000, 1) = 10
function M.percent(value, rate)
    return math.floor(value * rate / 100)
end

-- 千分比 util.permillage(1000, 1) = 1
function M.permillage(value, rate)
    return math.floor(value * rate / 1000)
end

return M
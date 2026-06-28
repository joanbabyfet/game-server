local skynet = require "skynet"

-- 启动入口, 负责启动所有服务
skynet.start(function()
    -- 启动 debug_console 服务并绑定 8000 端口
    skynet.newservice("debug_console", "0.0.0.0", 8000)

    -- 配置中心
    local config_mgr = skynet.newservice("config_mgr")
    -- 定时同步
    skynet.newservice("jackpot_sync")
    -- 创建全局唯一服务
    local game_mgr = skynet.uniqueservice("game_mgr")
    -- 创建服务（Actor）, 创建一个独立Lua VM 及 消息队列
    local gate = skynet.newservice("gate")
    local login = skynet.newservice("login")
    local slot = skynet.newservice("slot")
    local debug = skynet.newservice("debug")

    -- 自动测试 (放在最后)
    if skynet.getenv("debug") == "true" then
        local test = skynet.newservice("test")
        
        -- 发送1条 lua 消息给test服务(异步发送不阻塞启动流程), 每次服务器启动, 自动执行一次完整测试, 不需要手动输入任何命令
        skynet.send(test, "lua", "run")
    end

    skynet.error("game start success")
end)
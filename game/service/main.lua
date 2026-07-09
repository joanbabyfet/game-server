local skynet = require "skynet"

-- 启动入口, 负责启动所有服务
skynet.start(function()
    -- 启动 debug_console 服务并绑定 8000 端口
    skynet.newservice("debug_console", skynet.getenv("debug_host"), tonumber(skynet.getenv("debug_port")))

    -- 配置中心
    local config_mgr = skynet.uniqueservice("config_mgr")
    -- 定时同步
    skynet.newservice("jackpot_sync")
    skynet.newservice("rtp_sync")
    -- 游戏管理
    local game_mgr = skynet.uniqueservice("game_mgr")
    -- 在线玩家管理
    local player_mgr = skynet.uniqueservice("player_mgr")
    -- 业务服务
    local login = skynet.newservice("login")
    local slot = skynet.newservice("slot")
    local rollback = skynet.newservice("rollback")
    local debug = skynet.newservice("debug")
    -- 系统服务
    local system = skynet.uniqueservice("system")
    -- RPC Server
    local rpc = skynet.uniqueservice("rpc")

    -- 自动测试 (放在最后)
    if skynet.getenv("debug") == "true" then
        local test = skynet.newservice("test")
        
        -- 发送1条 lua 消息给test服务(异步发送不阻塞启动流程), 每次服务器启动, 自动执行一次完整测试, 不需要手动输入任何命令
        --skynet.send(test, "lua", "run")
    end

    skynet.error("game start success")
end)
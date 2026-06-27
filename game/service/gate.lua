local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register

local CMD = {}

-- 健康检查(对外接口, 可以被其它 Service 调用)
function CMD.ping()
    return "pong"
end

-- 负责客户端入口
skynet.start(function()

    skynet.error("[GATE] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        assert(f, "unknown cmd : " .. tostring(cmd))

        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".gate")
end)
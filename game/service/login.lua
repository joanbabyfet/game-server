local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local login_logic = require "logic.login"
local response = require "common.response"

local CMD = {}

-- 玩家登录
function CMD.login(username)
    local user, err = login_logic.login(username)

    if err then
        return response.error(err.code, err.msg)
    end

    return response.success(user)
end

skynet.start(function()

    skynet.error("[LOGIN] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        assert(f, "unknown cmd : " .. tostring(cmd))

        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".login")
end)
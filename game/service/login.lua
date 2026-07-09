local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local login_logic = require "logic.login"
local constant = require "common.constant"

local CMD = {}

-- 玩家登录
function CMD.login(username)
    local user, err = login_logic.login(username)

    if err then
        return nil, err
    end

    return user
end

skynet.start(function()

    skynet.error("[LOGIN] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        if not f then
            skynet.error(string.format(
                "[LOGIN] unknown cmd=%s source=%08x",
                tostring(cmd),
                source
            ))

            skynet.retpack(nil, {
                code = constant.ERROR.RPC_UNKNOWN_CMD,
                msg = "unknown cmd",
            })

            return
        end

        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".login")
end)
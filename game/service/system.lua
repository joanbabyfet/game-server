local skynet = require "skynet"
require "skynet.manager"
local constant = require "common.constant"

local CMD = {}

-- 健康检查(对外接口, 可以被其它 Service 调用)
function CMD.ping(req)
    return {
        msg = "pong",
        timestamp = os.time(),
    }
end

-- 对外提供系统级rpc服务入口
skynet.start(function()

    skynet.error("[SYSTEM] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        if not f then
            skynet.error(string.format(
                "[SYSTEM] unknown cmd=%s source=%08x",
                tostring(cmd),
                source
            ))

            skynet.retpack(nil, {
                code = constant.ERROR.RPC_UNKNOWN_CMD,
                msg = "unknown cmd",
            })

            return
        end

        skynet.retpack(f(...))

    end)

    -- 注册服务
    skynet.register(".system")

end)
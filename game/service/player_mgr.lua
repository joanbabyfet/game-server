local skynet = require "skynet"
require "skynet.manager"
local constant = require "common.constant"

local CMD = {}

local players = {}
local online_count = 0

-- 玩家上线
function CMD.online(uid)
    -- 防止重复上线
    if players[uid] then
        return false, "already online"
    end

    players[uid] = {
        uid = uid,
        login_time = skynet.time(),
    }

    online_count = online_count + 1

    return true
end

-- 玩家下线
function CMD.offline(uid)

    if not players[uid] then
        return false, "player not online"
    end

    players[uid] = nil

    online_count = online_count - 1

    return true
end

-- 是否在线
function CMD.is_online(uid)

    return players[uid] ~= nil

end

-- 获取玩家
function CMD.get(uid)

    return players[uid]

end

-- 在线人数
function CMD.count()

    return online_count

end

-- 踢玩家
function CMD.kick(uid)

    -- TODO
    -- 通知 Provider API 断开连接(由 Provider API 完成断连接)
    if not players[uid] then
        return nil, {
            code = constant.ERROR.USER_NOT_FOUND,
            msg = "user not found",
        }
    end

    local ok, err = CMD.offline(uid)
    if not ok then
        return nil, err
    end

    return {}
end

function CMD.authenticate(req)

    if players[req.uid] then
        return {
            success = true,
        }
    end

    local ok = CMD.online(req.uid)

    return {
        success = ok,
    }
end

-- 获取所有在线 uid（GM 用）, 返回 {1001,1002,1005}
function CMD.list()

    local list = {}

    for uid in pairs(players) do
        table.insert(list, uid)
    end

    return list

end

-- 在线玩家管理服务
-- 管理玩家在线状态、在线人数、GM 踢人等
skynet.start(function()

    skynet.error("[PLAYER_MGR] start")

    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]
        
        if not f then
            skynet.error(string.format(
                "[PLAYER_MGR] unknown cmd=%s source=%08x",
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
    skynet.register(".player_mgr")
end)
local skynet = require "skynet"
require "skynet.manager"
local constant = require "common.constant"

local CMD = {}

local players = {}
local online_count = 0

-- 玩家上线
function CMD.online(data)

    local uid = data.uid

    local player = players[uid]

    -- 防止重复上线, 已在线，覆盖 旧数据
    if player then
        player.login_time = skynet.time()

        return {}
    end

    players[uid] = {
        uid = uid,
        login_time = skynet.time(),
    }

    online_count = online_count + 1

    return {}
end

-- 玩家下线
function CMD.offline(uid)

    if not players[uid] then
        return nil, {
            code = constant.ERROR.PLAYER_NOT_ONLINE,
            msg = "player not online",
        }
    end

    players[uid] = nil

    online_count = online_count - 1

    return {}
end

-- 是否在线
function CMD.is_online(uid)

   return {
        online = players[uid] ~= nil,
    }

end

-- 获取玩家
function CMD.get(uid)

    local player = players[uid]
    if not player then
        return nil, {
            code = constant.ERROR.PLAYER_NOT_ONLINE,
            msg = "player not online",
        }
    end

    return player

end

-- 在线人数
function CMD.count()

    return online_count

end

-- 踢玩家
function CMD.kick(data)

    local uid = data.uid

    local player = players[uid]

    -- 已经离线，幂等返回成功
    if not player then
        return {}
    end

    -- TODO
    -- 通知 Provider API / Gateway 断开连接

    players[uid] = nil
    online_count = online_count - 1

    return {}
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
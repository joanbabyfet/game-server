local pb = require "pb"
local protoc = require "protoc".new()
local skynet = require "skynet"

local M = {}

-- 初始化 Proto
function M.init()
    -- Proto 搜索目录
    protoc:addpath("/app/proto")

    local files = {
        "common.proto",
        "rpc.proto",
        "system.proto",
        "user.proto",
        --"wallet.proto",
        --"slot.proto",
    }

    for _, file in ipairs(files) do
        assert(protoc:loadfile(file))
    end
end

-- Encode
function M.encode(message, data)

    return assert(pb.encode(message, data))

end

-- Decode
function M.decode(message, bytes)

    return assert(pb.decode(message, bytes))

end

return M
local skynet = require "skynet"
local socket = require "skynet.socket"

local codec = require "rpc.codec"
local dispatcher = require "rpc.dispatcher"
local protobuf = require "rpc.protobuf"

local function serve(fd)

    while true do

        local packet = codec.read_packet(fd)

        if not packet then
            break
        end

        local ok, result = xpcall(function()

            -- 保存多个返回值
            return { dispatcher.dispatch(packet) }

        end, debug.traceback)

        --------------------------------------------------
        -- Lua Runtime Error
        --------------------------------------------------

        if not ok then

            skynet.error(result)

            socket.write(
                fd,
                codec.encode_error(packet.seq, {
                    code = -1,
                    msg = "internal error",
                })
            )

        else

            local resp = result[1]
            local err  = result[2]

            --------------------------------------------------
            -- Business Error
            --------------------------------------------------

            if err then

                socket.write(
                    fd,
                    codec.encode_error(packet.seq, err)
                )

            --------------------------------------------------
            -- Success
            --------------------------------------------------

            else

                socket.write(
                    fd,
                    codec.encode_response(
                        packet.cmd,
                        packet.seq,
                        resp or {}
                    )
                )

            end

        end

    end

end

skynet.start(function()

    protobuf.init()

    local host = skynet.getenv("rpc_host") or "0.0.0.0"
    local port = tonumber(skynet.getenv("rpc_port")) or 8888

    local listen_fd = assert(socket.listen(host, port))

    socket.start(listen_fd, function(fd, addr)

        -- 启动客户端连接
        socket.start(fd)

        skynet.error(string.format(
            "[RPC] client connected %s",
            addr
        ))

        skynet.fork(function()

            local ok, err = xpcall(function()

                serve(fd)

            end, debug.traceback)

            socket.close(fd)

            if not ok then
                skynet.error(err)
            end

        end)

    end)

    skynet.error(string.format(
        "[RPC] server start %s:%d",
        host,
        port
    ))

end)
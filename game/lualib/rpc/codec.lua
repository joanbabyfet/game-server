local socket = require "skynet.socket"
local pb = require "pb"
local proto_map = require "rpc.proto_map"

local M = {}

----------------------------------------------------------
-- Packet Type
--
-- REQUEST  : Client -> Server
-- RESPONSE : Server -> Client
-- ERROR    : Server -> Client (RPC Error)
----------------------------------------------------------

M.TYPE = {
    REQUEST  = 0,
    RESPONSE = 1,
    ERROR    = 2,
}

----------------------------------------------------------
-- Big Endian
----------------------------------------------------------

local function pack_u8(v)
    return string.char(v % 256)
end

local function pack_u16(v)
    return string.char(
        math.floor(v / 256) % 256,
        v % 256
    )
end

local function pack_u32(v)
    return string.char(
        math.floor(v / 16777216) % 256,
        math.floor(v / 65536) % 256,
        math.floor(v / 256) % 256,
        v % 256
    )
end

local function unpack_u8(data)
    return data:byte(1)
end

local function unpack_u16(data)
    local b1, b2 = data:byte(1, 2)
    return b1 * 256 + b2
end

local function unpack_u32(data)
    local b1, b2, b3, b4 = data:byte(1, 4)

    return
        b1 * 16777216 +
        b2 * 65536 +
        b3 * 256 +
        b4
end

----------------------------------------------------------
-- Encode Response Packet
--
-- Packet Layout
--
-- +------------+------+--------+--------+---------+
-- | Length(4)  |Type(1)|Cmd(2) |Seq(4)  | Payload |
-- +------------+------+--------+--------+---------+
--
-- Payload = Protobuf Response
----------------------------------------------------------

function M.encode_response(cmd, seq, resp)

    local meta = assert(proto_map[cmd], "unknown cmd : " .. tostring(cmd))

    local proto = pb.encode(meta.resp, resp)

    local body =
        pack_u8(M.TYPE.RESPONSE) ..
        pack_u16(cmd) ..
        pack_u32(seq) ..
        proto

    return pack_u32(#body) .. body

end

----------------------------------------------------------
-- Encode Error Packet
--
-- Payload = rpc.Error
----------------------------------------------------------

function M.encode_error(seq, err)

    local proto = pb.encode("rpc.Error", err)

    local body =
        pack_u8(M.TYPE.ERROR) ..
        pack_u16(0) ..
        pack_u32(seq) ..
        proto

    return pack_u32(#body) .. body

end

----------------------------------------------------------
-- Decode Request Packet
----------------------------------------------------------

function M.read_packet(fd)

    local LENGTH_SIZE = 4

    local TYPE_SIZE = 1
    local CMD_SIZE  = 2
    local SEQ_SIZE  = 4

    ------------------------------------------------------
    -- Read Length
    ------------------------------------------------------

    local len_buf = socket.read(fd, LENGTH_SIZE)

    if not len_buf then
        return nil
    end

    local body_len = unpack_u32(len_buf)

    ------------------------------------------------------
    -- Read Body
    ------------------------------------------------------

    local body = socket.read(fd, body_len)

    if not body then
        return nil
    end

    ------------------------------------------------------
    -- Decode Header
    ------------------------------------------------------

    local offset = 1

    -- Packet Type
    local packet_type =
        unpack_u8(body:sub(offset, offset))

    offset = offset + TYPE_SIZE

    -- Command ID
    local cmd =
        unpack_u16(body:sub(offset, offset + CMD_SIZE - 1))

    offset = offset + CMD_SIZE

    -- Sequence ID
    local seq =
        unpack_u32(body:sub(offset, offset + SEQ_SIZE - 1))

    offset = offset + SEQ_SIZE

    ------------------------------------------------------
    -- Decode Request Payload
    ------------------------------------------------------

    local meta = proto_map[cmd]

    if not meta then
        error("unknown cmd : " .. tostring(cmd))
    end

    local bytes = body:sub(offset)

    local req = pb.decode(meta.req, bytes)

    ------------------------------------------------------
    -- Packet
    ------------------------------------------------------

    return {
        type = packet_type,
        cmd  = cmd,
        seq  = seq,
        data = req,
    }

end

return M
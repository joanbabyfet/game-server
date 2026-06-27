local CODE = require "common.code"

local M = {}

function M.success(data, msg)
    return {
        code = CODE.SUCCESS,
        msg = msg or "success",
        timestamp = os.time(),
        data = data
    }
end

function M.error(code, msg)
    return {
        code = code or -1,
        msg = msg or "error",
        timestamp = os.time(),
        data = nil,
    }
end

return M
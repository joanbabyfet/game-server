local CONSTANT = require "common.constant"

local M = {}

function M.success(data, msg)
    return {
        code = CONSTANT.ERROR.SUCCESS,
        msg = msg or "success",
        timestamp = os.time(),
        data = data
    }
end

function M.error(code, msg)
    return {
        code = code or CONSTANT.ERROR.FAIL,
        msg = msg or "error",
        timestamp = os.time(),
        data = nil,
    }
end

return M
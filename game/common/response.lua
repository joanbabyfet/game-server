local CONSTANT = require "common.constant"

-- 这是给 Provider API（HTTP）用的，而不是 Skynet Service 之间调用用的
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
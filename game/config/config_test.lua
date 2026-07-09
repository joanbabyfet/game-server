root = "/app/skynet/"

thread = 8
harbor = 0

bootstrap = "snlua bootstrap"
-- 项目入口
start = "main"

-- skynet框架
lualoader = root .. "lualib/loader.lua"

-- 先找 game/service，再找 skynet/service
luaservice = "./service/?.lua;" .. root .. "service/?.lua"

-- Lua搜索路径
lua_path =
    "./?.lua;"
    .. "./?/init.lua;"
    .. "./lualib/?.lua;"
    .. "./lualib/?/init.lua;"
    .. root .. "lualib/?.lua;"
    .. root .. "lualib/?/init.lua"

-- C模块
lua_cpath = root .. "luaclib/?.so"

-- C Service
cpath = root .. "cservice/?.so"

logger = nil

debug = true

rpc_host = "0.0.0.0"

rpc_port = 8888

debug_host = "0.0.0.0"

debug_port = 8000
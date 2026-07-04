local skynet = require "skynet"
require "skynet.manager" -- 加载此模块后才能调用 skynet.register
local json = require "json"
local game_config_model = require "model.game_config"
local game_model = require "model.game"
local agent_game_model = require "model.agent_game"

local CMD = {}

local CONFIG = {}

local AGENT_GAME = {}

local VERSION = 0

-- 构建 Symbol Map
local function build_symbol_map(game_cfg)

    local symbol_map = {}

    local symbols = game_cfg.symbols

    if not symbols then
        return
    end

    for _, symbol in ipairs(symbols) do
        symbol_map[symbol.type] = symbol.id
    end

    game_cfg.symbol_map = symbol_map
end

-- 加载全部配置(内部函数, 只有 service 自己可以调用)
local function load_all()
    
    local games = game_model.get_all()
    local configs = game_config_model.get_all()

    local new_config = {}

    -- game 表
    for _, game in ipairs(games) do

        new_config[game.id] = {
            game_code = game.game_code,
            game_name = game.game_name,
            status = game.status,
            maintenance = game.maintenance,
            maintenance_msg = game.maintenance_msg,
        }
    end

    for _, row in ipairs(configs) do

        local game_id = row.game_id

        if not new_config[game_id] then
            new_config[game_id] = {}
        end

        new_config[game_id][row.config_key] =
            json.decode(row.config_value)
    end

    -- 构建 Symbol Map
    for _, game_cfg in pairs(new_config) do
        build_symbol_map(game_cfg)
    end

    CONFIG = new_config

    VERSION = VERSION + 1

    skynet.error(string.format(
        "[CONFIG] load success version=%d games=%d configs=%d",
        VERSION,
        #games,
        #configs
    ))
end

-- 加载单个游戏配置
local function load_game(game_id)

    local game = game_model.get(game_id)

    if not game then
        CONFIG[game_id] = nil
        return
    end

    local rows = game_config_model.get_by_game(game_id)

    local game_cfg = {
        game_code = game.game_code,
        game_name = game.game_name,
        status = game.status,
        maintenance = game.maintenance,
        maintenance_msg = game.maintenance_msg,
    }

    for _, row in ipairs(rows) do
        game_cfg[row.config_key] = json.decode(row.config_value)
    end

    build_symbol_map(game_cfg)

    CONFIG[game_id] = game_cfg

    VERSION = VERSION + 1

    skynet.error(string.format(
        "[CONFIG] reload game=%d version=%d",
        game_id,
        VERSION
    ))
end

local function load_agent_game()

    AGENT_GAME = {}

    local list = agent_game_model.list()

    for _, v in ipairs(list) do

        if not AGENT_GAME[v.agent_id] then
            AGENT_GAME[v.agent_id] = {}
        end

        AGENT_GAME[v.agent_id][v.game_id] = v

    end

    skynet.error(string.format(
        "[CONFIG] load agent_game=%d",
        #list
    ))
end

-- 获取某个游戏配置
function CMD.get_game(game_id)

    return CONFIG[game_id]

end

-- 获取指定配置
function CMD.get(game_id, key)

    local game = CONFIG[game_id]

    if not game then
        return nil
    end

    return game[key]

end

-- 获取全部游戏配置
function CMD.get_all()

    return CONFIG

end

-- 获取配置版本
function CMD.version()

    return VERSION

end

-- 热更新全部配置
function CMD.reload()

    load_all()

    return VERSION

end

-- 热更新单个游戏配置
function CMD.reload_game(game_id)

    load_game(game_id)

    return VERSION

end

function CMD.get_agent_game(agent_id, game_id)

    local agent = AGENT_GAME[agent_id]
    if not agent then
        return nil
    end

    return agent[game_id]
end

function CMD.reload_agent_game()

    load_agent_game()

    return true
end

-- 健康检查(对外接口, 可以被其它 Service 调用)
function CMD.ping()
    return "pong"
end

-- config_mgr 本身就是一个常驻 Service
skynet.start(function()
    
    load_all()

    load_agent_game()

    -- 注册 Lua 消息处理函数
    skynet.dispatch("lua", function(session, source, cmd, ...)

        local f = CMD[cmd]

        assert(f, cmd)

        skynet.retpack(
            f(...)
        )

    end)

    -- 向 launcher 注册服务
    skynet.register(".config_mgr")

end)
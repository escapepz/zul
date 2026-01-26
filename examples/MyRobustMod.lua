-- MyRobustMod.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyRobustMod")

local function safeLoadConfig()
    logger:debug("Loading configuration")

    local success, config = pcall(function()
        -- Load config logic
        return loadConfigFile()
    end)

    if not success then
        logger:error("Failed to load config", {
            error = tostring(config)
        })
        return nil
    end

    logger:info("Configuration loaded successfully")
    return config
end

local function criticalOperation()
    logger:trace("Starting critical operation")

    local result, err = performOperation()

    if not result then
        logger:fatal("Critical operation failed", {
            error = err,
            timestamp = os.time()
        })
        -- Handle critical failure
        return false
    end

    logger:info("Critical operation completed")
    return true
end

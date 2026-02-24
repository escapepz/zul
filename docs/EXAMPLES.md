# ZUL Usage Examples

This document provides practical examples for mod developers using ZUL.

## Example 1: Simple Mod with Basic Logging

```lua
-- MySimpleMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MySimpleMod")

local function onPlayerSpawn(player)
    logger:info("Player spawned", {
        username = player:getUsername(),
        profession = player:getDescriptor():getProfession()
    })
end

local function onPlayerDeath(player)
    logger:warn("Player died", {
        username = player:getUsername(),
        zombieKills = player:getZombieKills()
    })
end

Events.OnPlayerSpawn.Add(onPlayerSpawn)
Events.OnPlayerDeath.Add(onPlayerDeath)
```

## Example 2: Mod with Debug Mode

```lua
-- MyDebugMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MyDebugMod")

-- Enable debug mode during development
local DEBUG_MODE = true

---@diagnostic disable-next-line: unnecessary-if
if DEBUG_MODE then
    logger:setLevel("DEBUG")
end

local function processData(data)
    logger:debug("Processing data", { size = #data })

    -- Expensive debug operation only when needed
    if ZUL.isLoggingEnabled("MyDebugMod", ZUL.Level.TRACE) then
        logger:trace("Data details", data)
    end

    -- ... process data ...

    logger:info("Data processed successfully")
end
```

## Example 3: Multi-Module Mod

```lua
-- Core.lua
local ZUL = require("zul")
local logger = ZUL.new("MyComplexMod")

local Core = {}

function Core.init()
    logger:info("Core module initialized")
end

return Core
```

```lua
-- Database.lua
local ZUL = require("zul")
local logger = ZUL.new("MyComplexMod")

local Database = {}

function Database.query(table, filter)
    logger:debug("Database", "Query", {
        table = table,
        filter = filter
    })

    -- ... query logic ...
end

return Database
```

```lua
-- Main.lua
local Core = require "Core"
local Database = require "Database"
local ZUL = require("zul")

-- Set global log level for the mod
ZUL.setLevel("MyComplexMod", "INFO")

Core.init()
Database.query("players", { active = true })
```

## Example 4: Error Handling with Logging

```lua
-- MyRobustMod.lua
local ZUL = require("zul")
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
```

## Example 5: Performance Monitoring

```lua
-- MyPerformanceMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MyPerformanceMod")

local function measurePerformance(name, fn)
    local startTime = os.clock()

    logger:trace("Performance", "Start", { operation = name })

    local result = fn()

    local elapsed = os.clock() - startTime

    if elapsed > 0.1 then
        logger:warn("Slow operation detected", {
            operation = name,
            duration = elapsed
        })
    else
        logger:debug("Performance", "Complete", {
            operation = name,
            duration = elapsed
        })
    end

    return result
end

-- Usage
local function expensiveCalculation()
    -- ... complex logic ...
end

measurePerformance("expensiveCalculation", expensiveCalculation)
```

## Example 6: Conditional Logging Based on Sandbox Options

```lua
-- MyConfigurableMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MyConfigurableMod")

local function init()
    -- (Optional) Force fresh sandbox stats if sync just occurred
    ZUL.loadSandboxOptions(true)

    -- Check if this mod should use ZUL settings
    if ZUL.shouldApplySandboxSettings("MyConfigurableMod") then
        logger:info("Using ZUL sandbox settings")
    else
        logger:info("Using custom log settings")
        logger:setLevel("DEBUG")
    end

    -- Log current effective level
    local level = logger:getEffectiveLevel()
    logger:debug("Current log level:", level)
end

Events.OnGameBoot.Add(init)
```

## Example 7: Structured Logging for Events

```lua
-- MyEventMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MyEventMod")

local function onVehicleEnter(player, vehicle)
    logger:info("Vehicle", "Enter", {
        player = player:getUsername(),
        vehicleType = vehicle:getScriptName(),
        vehicleId = vehicle:getId(),
        location = {
            x = vehicle:getX(),
            y = vehicle:getY()
        }
    })
end

local function onVehicleExit(player, vehicle)
    logger:info("Vehicle", "Exit", {
        player = player:getUsername(),
        vehicleType = vehicle:getScriptName(),
        vehicleId = vehicle:getId()
    })
end

Events.OnEnterVehicle.Add(onVehicleEnter)
Events.OnExitVehicle.Add(onVehicleExit)
```

## Example 8: Direct Console Debugging

Use `.log()` when you want immediate output in the game console/terminal without worrying about log levels or file-writing overhead.

```lua
-- MyDebugScript.lua
local ZUL = require("zul")
local logger = ZUL.new("DebugHelper")

local function onTick()
    -- This will print DIRECTLY to the console using print()
    -- It ignores log level filtering!
    logger:log("Current Tick", os.clock())

    -- This will only log if level is INFO or higher
    -- and uses writeLog() for persistence
    logger:info("Standard log")
end
```

## Example 9: Defensive Logger (Optional Dependency)

If you want your mod to work with or without ZUL, you can use a defensive wrapper.

```lua
-- MyDefensiveMod.lua
local hasZUL, ZUL = pcall(require, "zul")
local logger = nil

if hasZUL and type(ZUL) == "table" and type(ZUL.new) == "function" then
    local ok, result = pcall(ZUL.new, "MyDefensiveMod")
    if ok and result then
        logger = result
        pcall(function() logger:info("ZUL detected and enabled") end)
    end
end

local function safeLog(msg, debug)
    if logger then
        if debug then
            pcall(function() logger:debug(msg) end)
        else
            pcall(function() logger:info(msg) end)
        end
    elseif not debug then
        print("[MyDefensiveMod] " .. tostring(msg))
    end
end

return safeLog
```

## Best Practices

1. **Use Appropriate Log Levels**
    - TRACE: Very detailed debugging (e.g., loop iterations)
    - DEBUG: Debugging information (e.g., function calls, data processing)
    - INFO: Important events (e.g., initialization, player actions)
    - WARN: Warning conditions (e.g., deprecated usage, slow operations)
    - ERROR: Error conditions (e.g., failed operations, invalid data)
    - FATAL: Critical failures (e.g., mod cannot continue)

2. **Create One Logger Per Mod**

    ```lua
    -- Good
    local logger = ZUL.new("MyMod")

    -- Avoid creating multiple loggers for the same mod
    ```

3. **Use Structured Context**

    ```lua
    -- Good
    logger:info("Player action", { action = "craft", item = "axe" })

    -- Less useful
    logger:info("Player crafted axe")
    ```

4. **Check Log Level for Expensive Operations**

    ```lua
    if ZUL.isLoggingEnabled("MyMod", ZUL.Level.DEBUG) then
        local expensiveData = collectAllDebugInfo()
        logger:debug("Debug info", expensiveData)
    end
    ```

5. **Don't Log Sensitive Information**
    ```lua
    -- Avoid logging passwords, tokens, or personal data
    logger:debug("User login", { username = user.name }) -- OK
    logger:debug("User login", { password = user.password }) -- BAD!
    ```

-- MyDebugScript.lua
local ZUL = require "ZUL"
local logger = ZUL.new("DebugHelper")

local function onTick()
    -- This will print DIRECTLY to the console using print()
    -- It ignores log level filtering!
    logger:log("Current Tick", os.clock())

    -- This will only log if level is INFO or higher
    -- and uses writeLog() for persistence
    logger:info("Standard log")
end

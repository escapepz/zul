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

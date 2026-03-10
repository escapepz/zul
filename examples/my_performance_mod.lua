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
            duration = elapsed,
        })
    else
        logger:debug("Performance", "Complete", {
            operation = name,
            duration = elapsed,
        })
    end

    return result
end

-- Usage
local function expensiveCalculation()
    -- ... complex logic ...
end

measurePerformance("expensiveCalculation", expensiveCalculation)

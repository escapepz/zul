-- MyClientStressTest.lua
-- Goal: Verify that ZUL does not introduce noticeable FPS drops, log stalls, or GC pressure when logging is extremely noisy.

local hasZUL, ZUL = pcall(require, "ZUL")
---@diagnostic disable-next-line: impossible-if, unnecessary-if
if not hasZUL or type(ZUL) ~= "table" or not ZUL.new or not ZUL.Level then
    print("ZUL not found or invalid! Skipping stress test.")
    return
end

local logger = nil
local counter = 0
local isStressing = false
local STRESS_LIMIT = 500 -- Auto-stop after 500 ticks
local lastFPSValue = 0
local pzCalendar = nil

local function GetIRLTimestamp()
    return math.floor(os.time())
end

local function stressTick()
    if not isStressing or not logger then return end

    counter = counter + 1

    -- Auto-stop check
    if counter > STRESS_LIMIT then
        ZUL_StopStress()
        print("ZUL Stress Test: Auto-stopped after " .. STRESS_LIMIT .. " ticks")
        return
    end

    local realTime = GetIRLTimestamp()

    -- simulate extreme spam: 200 lines per tick
    for i = 1, 200 do
        logger:trace("StressTest", "TickSpam", {
            tick = counter,
            index = i,
            fps = lastFPSValue,
            timestamp = realTime
        })
    end
end

local function renderTick()
    if not isStressing then return end
    -- Assign current FPS to a local var instead of printing to minimize IO interference
    lastFPSValue = math.floor(getAverageFPS())
end

ZUL_StartStress = function()
    ---@diagnostic disable-next-line: impossible-if, unnecessary-if
    if not hasZUL then return end
    if isStressing then return end

    logger = ZUL.new("ZUL_Stress")
    logger:setLevel(ZUL.Level.TRACE)
    isStressing = true
    counter = 0
    pzCalendar = nil

    ---@diagnostic disable-next-line: impossible-if, unnecessary-if
    if Events and type(Events) == "table" and Events.OnTick then
        Events.OnTick.Add(stressTick)
        Events.OnRenderTick.Add(renderTick)
        print("ZUL Stress Test: Started (200 TRACE logs per tick, Auto-stop at " .. STRESS_LIMIT .. ")")
    else
        print("ZUL Stress Test: Events not available")
    end
end

-- Provide a way to stop it easily from console or menu
ZUL_StopStress = function()
    if not isStressing then return end
    isStressing = false

    ---@diagnostic disable-next-line: impossible-if, unnecessary-if
    if Events and type(Events) == "table" and Events.OnTick then
        Events.OnTick.Remove(stressTick)
        Events.OnRenderTick.Remove(renderTick)
    end
    print("ZUL Stress Test: Stopped (Last FPS: " .. tostring(lastFPSValue) .. ")")
end

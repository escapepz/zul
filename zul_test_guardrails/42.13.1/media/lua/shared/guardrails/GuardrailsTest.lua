-- zul_test/GuardrailsTest.lua
-- Local test for guardrails hook logic

local MODULE_NAME = "GuardrailsTest"

-- 1. Integration Setup
local hasZUL, ZUL = pcall(require, "ZUL")
if not hasZUL or type(ZUL) ~= "table" or not ZUL.serialize then
    print("[" .. MODULE_NAME .. "] ZUL not found or invalid! Hooks not applied.")
    return
end
require("guardrails/MyZULGuardrails")

local logger = ZUL.new(MODULE_NAME)

local function runTests()
    logger:info("--- Starting Guardrails Integration Tests ---")

    -- Test 1: Deny Keys
    logger:info("Test 1: Deny Keys")
    -- We use a raw table here; ZUL.serialize should now be the hooked version
    local sensitive = { public = "hello integration", modData = { secret = 123 }, knownRecipes = { "test" } }
    local serialized = ZUL.serialize(sensitive)

    logger:info("Input: public, modData, knownRecipes")
    logger:info("Serialized Result", { result = tostring(serialized) })

    if string.find(serialized, "modData") or string.find(serialized, "knownRecipes") then
        logger:error("FAILED: Sensitive keys found in output!")
    else
        logger:info("PASSED: Sensitive keys filtered.")
    end

    -- Test 2: Truncation
    logger:info("Test 2: Truncation (Max 20 keys)")
    local bigTable = {}
    for i = 1, 30 do bigTable["field" .. i] = i end
    local serializedBig = ZUL.serialize(bigTable)

    logger:info("Input: 30 keys")
    if string.find(serializedBig, "_truncated=true") then
        logger:info("PASSED: Table truncated as expected.")
    else
        logger:error("FAILED: Table not truncated! Result: " .. tostring(serializedBig))
    end

    -- Test 3: Normal small table
    logger:info("Test 3: Small table")
    local small = { x = 10, y = 20 }
    local serializedSmall = ZUL.serialize(small)
    logger:info("Serialized Result", { result = serializedSmall })

    if string.find(serializedSmall, "x=10") and string.find(serializedSmall, "y=20") and not string.find(serializedSmall, "_truncated") then
        logger:info("PASSED: Small table preserved.")
    else
        logger:error("FAILED: Small table corrupted.")
    end

    logger:info("--- Guardrails Integration Tests Finished ---")
end

-- 2. Execution Logic
-- Run late (OnInitWorld or OnGameStart) to ensure MyZULGuardrails has finished its OnGameBoot logic
---@diagnostic disable-next-line: unnecessary-if
if Events and Events.OnInitWorld then
    Events.OnInitWorld.Add(runTests)
    logger:debug("Test scheduled for OnInitWorld")
else
    -- Fallback for standalone/mock debugging
    runTests()
end

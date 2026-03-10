-- @author eScape <https://github.com/escapepz/ZUL>

-- zul_test_client.lua
-- Scenario: Included in Global Log Level
-- Expected: Should adopt Global Level (e.g., DEBUG/TRACE messages appear)

local ZUL = require("zul")
local logger = ZUL.new("ZUL_Client")

local function runClientTests()
    if not isClient() and not isMultiplayer() then
        return
    end

    logger:info("--- Running Client ZUL Tests (Config: Included) ---")

    -- These should be VISIBLE if Global Level is set to DEBUG
    logger:trace("Client TRACE - Visible if Global is TRACE")
    logger:debug("Client DEBUG - Visible if Global is DEBUG")

    logger:info("Client INFO - Always Visible")

    -- Verify ZUL state for this mod
    logger:info("Mod Status", {
        modName = "ZUL_Client",
        effectiveLevel = logger:getEffectiveLevel(),
        isIncluded = ZUL.shouldApplySandboxSettings("ZUL_Client"),
        globalLevel = ZUL.sandboxOptions.globalLogLevel,
    })
end

Events.OnGameStart.Add(runClientTests)

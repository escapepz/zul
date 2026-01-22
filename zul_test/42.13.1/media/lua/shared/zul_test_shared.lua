-- @author eScape <https://github.com/escapepz/ZUL>

-- zul_test_shared.lua
-- Scenario: Excluded from Global Log Level
-- Expected: Only INFO and above should appear, even if Global is DEBUG/TRACE

local ZUL = require "ZUL"
local logger = ZUL.new("ZUL_Shared")

local function runSharedTests()
	logger:info("--- Running Shared ZUL Tests (Config: Excluded) ---")

	-- These should be SILENT if Global Level is DEBUG but we are Excluded
	logger:trace("Shared TRACE - Should be SILENT")
	logger:debug("Shared DEBUG - Should be SILENT")

	logger:info("Shared INFO - Should be VISIBLE")
	logger:warn("Shared WARN - Should be VISIBLE")

	-- Verify ZUL state for this mod
	logger:info("Mod Status", {
		modName = "ZUL_Shared",
		effectiveLevel = logger:getEffectiveLevel(),
		isIncluded = ZUL.shouldApplySandboxSettings("ZUL_Shared")
	})
end

Events.OnInitGlobalModData.Add(runSharedTests)

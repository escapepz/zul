-- @author eScape <https://github.com/escapepz/ZUL>

-- zul_test_server.lua
-- Scenario: Untracked (Not in Include list)
-- Expected: Should stay at INFO (default) even if Global is DEBUG

local ZUL = require("zul")
local logger = ZUL.new("ZUL_Server")

local function runServerTests()
	if not isServer() then return end

	logger:info("--- Running Server ZUL Tests (Config: Untracked) ---")

	-- Should be SILENT if there's an IncludeMods list and we aren't in it
	logger:trace("Server TRACE - Should be SILENT")
	logger:debug("Server DEBUG - Should be SILENT")

	logger:info("Server INFO - Should be VISIBLE")

	-- Verify ZUL state for this mod
	logger:info("Mod Status", {
		modName = "ZUL_Server",
		effectiveLevel = logger:getEffectiveLevel(),
		isIncluded = ZUL.shouldApplySandboxSettings("ZUL_Server")
	})
end

Events.OnServerStarted.Add(runServerTests)

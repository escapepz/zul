-- @author eScape <https://github.com/escapepz/ZUL>

-- zul_test_shared.lua
-- Shared test script to verify ZUL functionality on both sides

local ZUL = require "ZUL"

local function runSharedTests()
	local logger = ZUL.new("ZUL_Shared")
	logger:info("--- Running Shared ZUL Tests ---")

	-- Test: Basic logging on both sides
	logger:info("Shared logger test message")
	logger:debug("Shared debug message (if level >= DEBUG)")

	-- Test: Context logging
	logger:info("Shared action", { side = isServer() and "Server" or "Client", status = "online" })
end

Events.OnInitGlobalModData.Add(runSharedTests)

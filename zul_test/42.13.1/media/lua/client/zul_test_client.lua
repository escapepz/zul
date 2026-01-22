-- @author eScape <https://github.com/escapepz/ZUL>

-- zul_test_client.lua
-- Client-side test script for ZUL framework

local ZUL = require "ZUL"

local function runClientTests()
	if not isClient() and not isMultiplayer() then return end

	local logger = ZUL.new("ZUL_Client")
	logger:info("=== Running Client ZUL Test Suite ===")

	-- Test 1: Levels
	logger:trace("Client TRACE")
	logger:debug("Client DEBUG")
	logger:info("Client INFO")
	logger:warn("Client WARN")
	logger:error("Client ERROR")
	logger:fatal("Client FATAL")

	-- Test 2: Context
	logger:info("Player Interaction", { action = "openWindow", room = "bedroom" })

	-- Test 3: Sandbox Check (Client side)
	ZUL.loadSandboxOptions()
	---@diagnostic disable-next-line: unnecessary-if
	if ZUL.sandboxOptions.loaded then
		logger:info("Sandbox options detected on client", {
			globalLogLevel = ZUL.sandboxOptions.globalLogLevel,
			includeCount = #ZUL.sandboxOptions.includeMods
		})
	end

	logger:info("=== Client ZUL Tests Complete ===")
end

Events.OnGameStart.Add(runClientTests)

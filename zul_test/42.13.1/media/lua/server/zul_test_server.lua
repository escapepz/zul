-- @author eScape <https://github.com/escapepz/ZUL>

-- zul_test_server.lua
-- Server-side test script for ZUL framework

local ZUL = require "ZUL"

local function runServerTests()
	if not isServer() then return end

	local logger = ZUL.new("ZUL_Server")
	logger:info("=== Running Server ZUL Test Suite ===")

	-- Test 1: Levels
	logger:trace("Server TRACE")
	logger:debug("Server DEBUG")
	logger:info("Server INFO")
	logger:warn("Server WARN")
	logger:error("Server ERROR")
	logger:fatal("Server FATAL")

	-- Test 2: Database/System Context
	logger:info("System Event", { event = "server_restart", uptime = 3600 })

	-- Test 3: Sandbox Verification (Server side)
	ZUL.loadSandboxOptions()
	---@diagnostic disable-next-line: unnecessary-if
	if ZUL.sandboxOptions.loaded then
		logger:info("Sandbox options loaded on server", {
			globalLogLevel = ZUL.sandboxOptions.globalLogLevel
		})
	end

	logger:info("=== Server ZUL Tests Complete ===")
end

Events.OnServerStarted.Add(runServerTests)

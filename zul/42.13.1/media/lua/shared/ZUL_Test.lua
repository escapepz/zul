-- @author eScape <https://ko-fi.com/escapepz>


-- ZUL_Test.lua
-- Test script to verify ZUL functionality
-- This file can be removed in production

local ZUL = require "ZUL"

local function runTests()
	print("=== ZUL Framework Test Suite ===")
	
	-- Test 1: Basic logging
	print("\n[Test 1] Basic Logging")
	local logger1 = ZUL.new("TestMod1")
	logger1:trace("This is a TRACE message")
	logger1:debug("This is a DEBUG message")
	logger1:info("This is an INFO message")
	logger1:warn("This is a WARN message")
	logger1:error("This is an ERROR message")
	logger1:fatal("This is a FATAL message")
	
	-- Test 2: Logging with context
	print("\n[Test 2] Logging with Context")
	local logger2 = ZUL.new("TestMod2")
	logger2:info("Player action", { action = "craft", item = "axe" })
	logger2:debug("Database", "Query", { table = "players", rows = 10 })
	
	-- Test 3: Log level changes
	print("\n[Test 3] Log Level Changes")
	local logger3 = ZUL.new("TestMod3")
	logger3:setLevel("WARN")
	logger3:debug("This should NOT appear (level is WARN)")
	logger3:warn("This SHOULD appear (level is WARN)")
	logger3:error("This SHOULD appear (level is WARN)")
	
	-- Test 4: Programmatic level setting
	print("\n[Test 4] Programmatic Level Setting")
	ZUL.setLevel("TestMod4", ZUL.Level.TRACE)
	local logger4 = ZUL.new("TestMod4")
	logger4:trace("This SHOULD appear (level is TRACE)")
	print("TestMod4 effective level:", logger4:getEffectiveLevel())
	
	-- Test 5: Sandbox options (if available)
	print("\n[Test 5] Sandbox Options")
	ZUL.loadSandboxOptions()
	if ZUL.sandboxOptions.loaded then
		print("Sandbox options loaded successfully")
		print("Global log level:", ZUL.sandboxOptions.globalLogLevel or "not set")
		
		local includeCount = 0
		for _ in pairs(ZUL.sandboxOptions.includeMods) do
			includeCount = includeCount + 1
		end
		print("Include mods count:", includeCount)
		
		local excludeCount = 0
		for _ in pairs(ZUL.sandboxOptions.excludeMods) do
			excludeCount = excludeCount + 1
		end
		print("Exclude mods count:", excludeCount)
	else
		print("Sandbox options not available (expected in main menu)")
	end
	
	-- Test 6: Include/Exclude filtering
	print("\n[Test 6] Include/Exclude Filtering")
	-- Simulate sandbox settings
	ZUL.sandboxOptions.includeMods["IncludedMod"] = true
	ZUL.sandboxOptions.excludeMods["ExcludedMod"] = true
	
	print("Should apply to IncludedMod:", ZUL.shouldApplySandboxSettings("IncludedMod"))
	print("Should NOT apply to ExcludedMod:", ZUL.shouldApplySandboxSettings("ExcludedMod"))
	print("Should NOT apply to ZUL:", ZUL.shouldApplySandboxSettings("ZUL"))
	
	-- Test 7: Direct console logging (.log)
	print("\n[Test 7] Direct Console Logging (.log)")
	local logger7 = ZUL.new("TestMod7")
	logger7:log("This SHOULD appear in console via print()")
	logger7:log("Testing table output", { status = "ok", console = true })
	
	print("\n=== All Tests Complete ===")
end

-- Run tests on game boot
Events.OnGameBoot.Add(runTests)

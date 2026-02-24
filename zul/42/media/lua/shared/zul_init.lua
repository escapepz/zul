-- @author eScape <https://github.com/escapepz/ZUL>

-- media/lua/shared/zul_init.lua
-- Initialization script for ZUL framework
-- Loads sandbox options on game start

local ZUL = require("zul")

local function initializeZUL(force)
	local sandbox = ZUL.sandboxOptions
	local wasLoaded = sandbox.loaded

	-- Attempt loading
	ZUL.loadSandboxOptions(force)

	local isLoaded = sandbox.loaded
	local logger = ZUL.new("ZUL")
	-- We use TRACE here to ensure these internal lifecycle logs are always visible during debug/init
	logger:setLevel("TRACE")

	---@diagnostic disable-next-line: unnecessary-if
	-- Case 1: First time we successfully bound settings
	if not wasLoaded and isLoaded then
		ZUL._initLogged = true
		logger:info("ZUL Framework initialized with sandbox settings")
		logger:debug("Global Level: " .. (sandbox.globalLogLevel or "INFO"))

		local includeCount = 0
		for _ in pairs(sandbox.includeMods) do includeCount = includeCount + 1 end
		if includeCount > 0 then logger:debug("Filtering enabled for " .. includeCount .. " mods") end

		-- Case 2: We were already loaded, and we just forced an update (Server Sync)
	elseif wasLoaded and isLoaded and force then
		logger:trace("ZUL sandbox settings refreshed (Server Sync)")
		-- We don't log the full config again to keep logs clean,
		-- but the internal state is now updated with server values.

		-- Case 3: Still waiting for SandboxVars to exist
		---@diagnostic disable-next-line: unnecessary-if
	elseif not isLoaded then
		logger:trace("ZUL searching for SandboxVars...")
	end
end

-- Primary initialization path
-- Best effort, usually too early but handles specialized environments.
Events.OnGameBoot.Add(function()
	initializeZUL()
end)
-- Primary load point where sandbox settings become available.
Events.OnInitGlobalModData.Add(function()
	initializeZUL(true)
end)
-- Final safety check during world generation.
Events.OnInitWorld.Add(function()
	initializeZUL(true)
end)
-- Final entry check for Client and Server environments.
-- On the Server, OnGameStart will never fire (silent).
Events.OnGameStart.Add(function()
	initializeZUL(true)
end)
-- On the Client, OnServerStarted will never fire (silent).
Events.OnServerStarted.Add(function()
	initializeZUL(true)
end)

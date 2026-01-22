-- @author eScape <https://github.com/escapepz/ZUL>

-- ZUL_Init.lua
-- Initialization script for ZUL framework
-- Loads sandbox options on game start

local ZUL = require "ZUL"

local function initializeZUL()
	local sandbox = ZUL.sandboxOptions
	local wasLoaded = sandbox.loaded

	-- Attempt loading (safe to call as many times as needed; it hits the 'loaded' guard inside)
	ZUL.loadSandboxOptions()

	local isLoaded = sandbox.loaded
	local logger = ZUL.new("ZUL")

	---@diagnostic disable-next-line: unnecessary-if
	if not wasLoaded and isLoaded then
		-- Log configuration once settings are successfully bound
		logger:info("ZUL Framework initialized with sandbox settings")
		logger:debug("Global Level: " .. (ZUL.defaultLevel or "INFO"))

		local includeCount = 0
		for _ in pairs(sandbox.includeMods) do includeCount = includeCount + 1 end
		if includeCount > 0 then logger:debug("Filtering enabled for " .. includeCount .. " mods") end
		---@diagnostic disable-next-line: unnecessary-if
	elseif not isLoaded then
		-- Silent in production, but here for debugging early boot state
		logger:trace("ZUL searching for SandboxVars...")
	end
end

-- Primary initialization path
-- Best effort, usually too early but handles specialized environments.
Events.OnGameBoot.Add(initializeZUL)
-- Primary load point where sandbox settings become available.
Events.OnInitGlobalModData.Add(initializeZUL)
-- Final safety check during world generation.
Events.OnInitWorld.Add(initializeZUL)

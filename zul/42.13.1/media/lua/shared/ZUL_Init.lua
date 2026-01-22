-- @author eScape <https://ko-fi.com/escapepz>


-- ZUL_Init.lua
-- Initialization script for ZUL framework
-- Loads sandbox options on game start

local ZUL = require "ZUL"

local function initializeZUL()
	-- Only log if it's the first successful load or a significant status change
	local wasLoaded = ZUL.sandboxOptions.loaded
	ZUL.loadSandboxOptions()
	
	local logger = ZUL.new("ZUL")
	if not wasLoaded and ZUL.sandboxOptions.loaded then
		logger:info("ZUL Framework initialized with sandbox settings")
		logger:debug("Default log level:", ZUL.defaultLevel)
		
		-- Log include list
		local includeCount = 0
		for modName in pairs(ZUL.sandboxOptions.includeMods) do
			includeCount = includeCount + 1
		end
		if includeCount > 0 then
			logger:debug("Include mods count:", includeCount)
		else
			logger:debug("Include list empty - applying to all mods")
		end
		
		-- Log exclude list
		local excludeCount = 0
		for modName in pairs(ZUL.sandboxOptions.excludeMods) do
			excludeCount = excludeCount + 1
		end
		if excludeCount > 0 then
			logger:debug("Exclude mods count:", excludeCount)
		end
	elseif not ZUL.sandboxOptions.loaded then
		logger:info("ZUL Framework initialized (waiting for sandbox settings...)")
	end
end

-- Early initialization
Events.OnGameBoot.Add(initializeZUL)

-- World initialization (where SandboxVars are guaranteed on server)
Events.OnInitWorld.Add(initializeZUL)

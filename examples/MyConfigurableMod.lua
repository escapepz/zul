-- MyConfigurableMod.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyConfigurableMod")

local function init()
    -- (Optional) Force fresh sandbox stats if sync just occurred
    ZUL.loadSandboxOptions(true)

    -- Check if this mod should use ZUL settings
    if ZUL.shouldApplySandboxSettings("MyConfigurableMod") then
        logger:info("Using ZUL sandbox settings")
    else
        logger:info("Using custom log settings")
        logger:setLevel("DEBUG")
    end

    -- Log current effective level
    local level = logger:getEffectiveLevel()
    logger:debug("Current log level:", level)
end

Events.OnGameBoot.Add(init)

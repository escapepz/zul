-- Core.lua
local ZUL = require("zul")
local logger = ZUL.new("MyComplexMod")

local Core = {}

function Core.init()
    logger:info("Core module initialized")
end

return Core

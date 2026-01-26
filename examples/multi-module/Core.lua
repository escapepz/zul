-- Core.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyComplexMod")

local Core = {}

function Core.init()
    logger:info("Core module initialized")
end

return Core

-- Database.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyComplexMod")

local Database = {}

function Database.query(table, filter)
    logger:debug("Database", "Query", {
        table = table,
        filter = filter
    })

    -- ... query logic ...
end

return Database

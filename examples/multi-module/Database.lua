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

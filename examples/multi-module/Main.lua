-- Main.lua
local Core = require "Core"
local Database = require "Database"
local ZUL = require "ZUL"

-- Set global log level for the mod
ZUL.setLevel("MyComplexMod", "INFO")

Core.init()
Database.query("players", { active = true })

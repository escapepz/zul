-- MySimpleMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MySimpleMod")

local function onPlayerSpawn(player)
    logger:info("Player spawned", {
        username = player:getUsername(),
        profession = player:getDescriptor():getProfession(),
    })
end

local function onPlayerDeath(player)
    logger:warn("Player died", {
        username = player:getUsername(),
        zombieKills = player:getZombieKills(),
    })
end

Events.OnPlayerSpawn.Add(onPlayerSpawn)
Events.OnPlayerDeath.Add(onPlayerDeath)

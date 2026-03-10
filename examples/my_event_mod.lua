-- MyEventMod.lua
local ZUL = require("zul")
local logger = ZUL.new("MyEventMod")

local function onVehicleEnter(player, vehicle)
    logger:info("Vehicle", "Enter", {
        player = player:getUsername(),
        vehicleType = vehicle:getScriptName(),
        vehicleId = vehicle:getId(),
        location = {
            x = vehicle:getX(),
            y = vehicle:getY(),
        },
    })
end

local function onVehicleExit(player, vehicle)
    logger:info("Vehicle", "Exit", {
        player = player:getUsername(),
        vehicleType = vehicle:getScriptName(),
        vehicleId = vehicle:getId(),
    })
end

Events.OnEnterVehicle.Add(onVehicleEnter)
Events.OnExitVehicle.Add(onVehicleExit)

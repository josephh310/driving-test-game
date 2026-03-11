--[[
    @Title: Obstacle Teleport
    @Author: Joseph (BreakLoop)
    @Description: Resets the player's vehicle position when triggered by an obstacle collision.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)

return function(obstacle: Model | BasePart, hit: BasePart)
	VehicleServiceClient:reset_vehicle_position()
end

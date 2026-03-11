--[[
    @Title: Spawn Vehicle Command
    @Author: Joseph (BreakLoop)
    @Description: Admin command that spawns a specified vehicle for a target player.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchShared = require(ReplicatedStorage.Shared.Services.Conch.ConchShared)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)

return {
	description = "Spawns a given vehicle for a player",
	permissions = {
		ConchShared.permissions.spawn_vehicles,
	},
	arguments = function()
		local player = Conch.args.player("player", "The player who the vehicle should be spawned for")
		local vehicle = Conch.args.string("vehicle", "The name of the vehicle")
		return player, vehicle
	end,
	callback = function(player, vehicle)
		VehicleServiceServer:spawn_vehicle(player, vehicle)
	end,
}

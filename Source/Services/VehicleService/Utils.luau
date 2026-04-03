--[[
    @Title: Vehicle Utilities
    @Author: 010DevX101
    @Description: Utility functions for vehicle management, including spawn CFrame selection and player-vehicle lookups.
]]

local Players = game:GetService("Players")
local VehicleUtils = {}

local SpawnedVehicles = workspace.Vehicles
local Map = workspace.Map
local Stages = Map.Stages

export type VehicleUtils = typeof(VehicleUtils)

function VehicleUtils.get_spawn_cframe_for_stage(self: VehicleUtils, stage: number)
	-- Get the stage object
	local Stage = Stages:FindFirstChild(tostring(stage))

	-- Get the spawns from the stage's folder
	local Spawns = Stage:FindFirstChild("Spawns")
	if not Spawns or not Spawns:IsA("Folder") then
		warn(`Stage {stage} does not contain a Spawns directory!`)
		return
	end

	-- Select a random, non-occupied spawn (fallback to a random one)
	local spawns = Spawns:GetChildren()
	local selected_spawn: BasePart = spawns[math.random(1, #spawns)]
	local overlap_params = OverlapParams.new()
	overlap_params.FilterType = Enum.RaycastFilterType.Include
	overlap_params.MaxParts = 1
	for _, spawn in spawns do
		if not spawn:IsA("BasePart") then
			continue
		end
		overlap_params.FilterDescendantsInstances = SpawnedVehicles:GetChildren()
		local part_bounds_in_box = workspace:GetPartBoundsInBox(spawn.CFrame, spawn.Size, overlap_params)
		if #part_bounds_in_box > 0 then
			continue
		end
		selected_spawn = spawn
	end

	return selected_spawn.CFrame
end

function VehicleUtils.get_player_from_vehicle(self: VehicleUtils, vehicle: Model)
	local player_name = vehicle.Name
	local player = Players:FindFirstChild(player_name)
	if not player then
		warn(`{vehicle} has no player.`)
		return
	end
	return player
end

function VehicleUtils.get_vehicle_from_player(self: VehicleUtils, player: Player)
	local vehicle_name = player.Name
	local vehicle = SpawnedVehicles:FindFirstChild(vehicle_name)
	if not vehicle then
		warn(`{player} has no spawned vehicle.`)
		return
	end
	return vehicle
end

return VehicleUtils

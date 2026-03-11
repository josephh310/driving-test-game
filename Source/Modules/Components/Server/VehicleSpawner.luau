--[[
    @Title: Vehicle Spawner
    @Author: Joseph (BreakLoop)
    @Description: Periodically spawns random dummy vehicles that tween from a start point to an end point, simulating traffic.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Vehicles = ReplicatedStorage.Assets.DummyVehicles:GetChildren()

return function(spawn_model: Model)
	-- Constants
	local spawn_start = spawn_model.Start
	local spawn_end = spawn_model.End
	local spawn_delay = spawn_model:GetAttribute("SpawnDelay")
	local travel_time = spawn_model:GetAttribute("TravelTime")

	-- Loop
	local thread = task.defer(function()
		while task.wait(spawn_delay) do
			-- Spawn a new vehicle
			local random_index = math.random(1, #Vehicles)
			local random_vehicle = Vehicles[random_index]:Clone() :: Model
			random_vehicle.Parent = workspace.Debris

			-- Set the position to the starting point of the vehicle spawn
			-- This os so we can tween the car across from (start -> end)
			random_vehicle:PivotTo(spawn_start.CFrame)

			-- Create the tweeen
			local vehicle_tween = TweenService:Create(
				random_vehicle.PrimaryPart,
				TweenInfo.new(travel_time),
				{ CFrame = spawn_end.CFrame }
			)

			-- Play the tween
			vehicle_tween:Play()
			vehicle_tween.Completed:Once(function()
				random_vehicle:Destroy()
				vehicle_tween:Destroy()
			end)
		end
	end)
	-- Destructor
	return function()
		task.cancel(thread)
	end
end

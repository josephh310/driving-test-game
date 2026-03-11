--[[
    @Title: Parking Space
    @Author: Joseph (BreakLoop)
    @Description: Detects when the local player's vehicle is fully parked within a designated region and activates the space on success.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

return function(root: BasePart)
	-- Constants
	local region_indicator = root.Parent
	local values = region_indicator.Values
	local sides = region_indicator.Sides

	-- Color observer
	local stop_observing_color = Observers.observeProperty(values.BorderColor, "Value", function(border_color: Color3)
		for _, side_part in sides:GetChildren() do
			if not side_part:IsA("BasePart") then
				continue
			end
			for _, surface_gui in side_part:GetChildren() do
				if not surface_gui:IsA("SurfaceGui") then
					continue
				end
				surface_gui.Frame.UIGradient.Color = ColorSequence.new(border_color)
			end
		end
	end)

	-- Root touched listener
	local touched_connection = root.Touched:Connect(function(hit: BasePart)
		if values.Activated.Value == true then
			return
		end
		if not hit:HasTag("VehicleHitbox") then
			return
		end
		print(`hit is a hitbox`)
		local vehicle = hit.Parent
		local player = VehicleServiceUtils:get_player_from_vehicle(vehicle)
		if player ~= Players.LocalPlayer then
			return
		end
		print(`hit has been linked to the local player`)

		-- The local player is within the region
		local stopped_touching = false
		local touch_ended_connection = nil :: RBXScriptConnection
		touch_ended_connection = hit.TouchEnded:Connect(function(part: BasePart)
			if part == root then
				print(`hit touch ended`)
				stopped_touching = true
				touch_ended_connection:Disconnect()
			end
		end)

		-- Repeat until the player leaves the region
		local parking_success = false
		local vehicle_parts = vehicle:QueryDescendants("BasePart")
		repeat
			task.wait()
			local overlapping_parts = workspace:GetPartsInPart(root)
			local vehicle_parts_overlapping = 0
			for index, base_part in vehicle_parts do
				if table.find(overlapping_parts, base_part) then
					vehicle_parts_overlapping += 1
				end
			end
			if vehicle_parts_overlapping == #vehicle_parts then
				parking_success = true
			end
		until stopped_touching == true or parking_success == true

		-- Check
		if parking_success then
			values.BorderColor.Value = Color3.fromRGB(0, 255, 0)
			values.Activated.Value = true
		end
	end)

	return function()
		stop_observing_color()
		touched_connection:Disconnect()
	end
end

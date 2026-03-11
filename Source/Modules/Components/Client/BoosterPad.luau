--[[
    @Title: Booster Pad
    @Author: Joseph (BreakLoop)
    @Description: Applies a forward impulse to the local player's vehicle when it touches the pad, with a configurable cooldown.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

local DEFAULT_PAD_COOLDOWN = 3

return function(pad: BasePart)
	-- State
	local on_cooldown = false

	-- Attributes
	local cooldown_time = pad:GetAttribute("Cooldown") or DEFAULT_PAD_COOLDOWN
	local impulse_strength = pad:GetAttribute("ImpulseStrength") or 100

	-- Touched connection
	local touched_connection = pad.Touched:Connect(function(hit: BasePart)
		-- Ensure the pad is not on cooldown
		if on_cooldown then
			return
		end

		-- Ensure the part is a hitbox of a valid vehicle and that the vehicle belongs to the player
		if not hit:HasTag("VehicleHitbox") then
			return
		end
		if VehicleServiceUtils:get_player_from_vehicle(hit.Parent) ~= Players.LocalPlayer then
			return
		end

		-- Impulse the vehicle forewards
		local vehicle_root = hit.Parent.PrimaryPart or hit
		vehicle_root:ApplyImpulse(vehicle_root.CFrame.LookVector * impulse_strength)

		-- Put the pad on cooldown
		on_cooldown = true

		-- Reset cooldown after the specified time
		task.delay(cooldown_time, function()
			on_cooldown = false
		end)
	end)

	-- Destructor
	return function()
		touched_connection:Disconnect()
	end
end

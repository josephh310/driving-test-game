--[[
    @Title: Obstacle
    @Author: Joseph (BreakLoop)
    @Description: Core obstacle component that detects vehicle collisions and dispatches configurable effects such as damage, impulse, sound, slippery, teleport, and dummy.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DummyEffect = require(script.Dummy)
local CollisonSound = require(script.SoundEffect)
local DealDamage = require(script.Damage)
local Impulse = require(script.Impulse)
local Slippery = require(script.Slippery)
local Teleport = require(script.Teleport)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

local DEFAULT_COOLDOWN = 3

return function(obstacle: Model | BasePart)
	-- Cooldown management
	local on_cooldown = false
	local obstacle_cooldown = obstacle:GetAttribute("Cooldown") or DEFAULT_COOLDOWN

	-- Trove to hold touched connections + parts of interest
	local trove = Trove.new()
	local parts = obstacle:QueryDescendants("BasePart")

	-- If the main obstacle instance is a base part rather than a model,
	-- we should add it to the parts of interest so it can be interacted with
	if obstacle:IsA("BasePart") then
		parts[#parts + 1] = obstacle
	end

	-- Touched function
	local function part_touched(part: BasePart, hit: BasePart)
		-- Reject if the player has recently interacted with the obstacle
		-- Prevents damage stacking
		if on_cooldown then
			return
		end

		-- Check the part touching the obstacle is a vehicle hitbox
		if not hit:HasTag("VehicleHitbox") then
			return
		end

		-- Fetch the player the hitbox belongs to
		local player = VehicleServiceUtils:get_player_from_vehicle(hit.Parent)

		-- If the player is invalid or not the local player, reject
		if not player or player ~= Players.LocalPlayer then
			return
		end

		-- Run obstacle functions
		if obstacle:GetAttribute("Damage") == true then
			print("Damage")
			DealDamage(obstacle, hit)
		end
		if obstacle:GetAttribute("Dummy") == true then
			print("Dummy")
			DummyEffect(obstacle, hit)
		end
		if obstacle:GetAttribute("SoundEffect") == true then
			print("Sound")
			CollisonSound(obstacle, hit)
		end
		if obstacle:GetAttribute("Impulse") == true then
			print("Impulse")
			Impulse(obstacle, hit)
		end
		if obstacle:GetAttribute("Slippery") then
			print("Slippery")
			Slippery(obstacle, hit)
		end
		if obstacle:GetAttribute("Teleport") == true then
			print("Teleport")
			Teleport()
		end

		-- Put the obstacle on cooldown
		on_cooldown = true
		task.delay(obstacle_cooldown, function()
			on_cooldown = false
		end)
	end

	-- Connect touched events
	for index, part in parts do
		trove:Connect(part.Touched, function(hit: BasePart)
			part_touched(part, hit)
		end)
	end

	return function()
		trove:Destroy()
		trove = nil
	end
end

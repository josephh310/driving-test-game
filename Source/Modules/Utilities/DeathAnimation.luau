--[[
    @Title: Death Animation
    @Author: Joseph (BreakLoop) and Claude
    @Description: Plays a vehicle self-destruct animation that breaks the model into parts with an explosion, fire, and smoke.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local rng = Random.new()

local EXPLOSION_FORCE = 40
local SPIN_SPEED = 15
local BURN_DURATION = 1.5
local CLEANUP_DELAY = 4

return function(vehicle: Model)
	local primary_part = vehicle.PrimaryPart
	if not primary_part then
		vehicle:Destroy()
		return
	end

	local center = primary_part.Position
	local parts: { BasePart } = {}

	-- Collect all base parts from the vehicle
	for _, descendant in vehicle:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end

	-- Disable constraints so parts fly apart
	for _, descendant in vehicle:QueryDescendants("WeldConstraint") do
		descendant:Destroy()
	end

	-- Unanchor all parts so physics can take over
	-- Disable massless so that the explosion is realistic
	for _, part in parts do
		part.Anchored = false
		part.Massless = false
	end

	-- Flash the vehicle white briefly before the explosion
	local original_colors: { [BasePart]: Color3 } = {}
	for _, part in parts do
		original_colors[part] = part.Color
		part.Color = Color3.new(1, 1, 1)
	end
	task.delay(0.1, function()
		for _, part in parts do
			if part.Parent then
				part.Color = original_colors[part]
			end
		end
	end)

	-- Apply explosive force and random spin to each part
	for _, part in parts do
		local direction = (part.Position - center).Unit
		if direction ~= direction then -- NaN check for parts at the exact center
			direction = Vector3.new(rng:NextNumber(-1, 1), 1, rng:NextNumber(-1, 1)).Unit
		end

		local force = direction * EXPLOSION_FORCE + Vector3.new(0, EXPLOSION_FORCE * 0.6, 0)
		part:ApplyImpulse(force * part.Mass)

		local spin = Vector3.new(
			rng:NextNumber(-SPIN_SPEED, SPIN_SPEED),
			rng:NextNumber(-SPIN_SPEED, SPIN_SPEED),
			rng:NextNumber(-SPIN_SPEED, SPIN_SPEED)
		)
		part:ApplyAngularImpulse(spin * part.Mass)
	end

	-- Spawn explosion effect at the center
	local explosion = Instance.new("Explosion")
	explosion.Position = center
	explosion.BlastRadius = 0
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = workspace
	Debris:AddItem(explosion, 2)

	-- Add fire and smoke to a few random parts
	local fire_count = math.min(#parts, 4)
	local shuffled = table.clone(parts)
	for i = #shuffled, 2, -1 do
		local j = rng:NextInteger(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	for i = 1, fire_count do
		local part = shuffled[i]

		local fire = Instance.new("Fire")
		fire.Size = rng:NextNumber(3, 6)
		fire.Heat = rng:NextNumber(5, 10)
		fire.Parent = part

		local smoke = Instance.new("Smoke")
		smoke.Size = rng:NextNumber(2, 5)
		smoke.Opacity = 0.4
		smoke.RiseVelocity = rng:NextNumber(3, 8)
		smoke.Parent = part

		-- Extinguish fire after burn duration
		task.delay(BURN_DURATION, function()
			fire.Enabled = false
			smoke.Enabled = false
		end)
	end

	-- Fade out all parts and destroy the vehicle
	task.delay(BURN_DURATION, function()
		for _, part in parts do
			if part.Parent then
				TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Transparency = 1,
				}):Play()
			end
		end

		task.delay(CLEANUP_DELAY - BURN_DURATION, function()
			if vehicle.Parent then
				vehicle:Destroy()
			end
		end)
	end)
end

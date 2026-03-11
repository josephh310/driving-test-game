--[[
    @Title: Obstacle Sound Effect
    @Author: Joseph (BreakLoop)
    @Description: Plays a collision sound effect from the obstacle when hit, using either a custom or randomly selected impact sound.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaySoundFromPart = require(ReplicatedStorage.Shared.Modules.Utilities.PlaySoundFromPart)
local HitSounds = ReplicatedStorage.Assets.SoundEffects.ImpactSounds:GetChildren()

return function(obstacle: Model | BasePart, hit: BasePart)
	-- Attributes
	local custom_sound = obstacle:GetAttribute("SoundEffect_Sound")

	-- Find a valid part to play the sound from (spatial audio)
	local part = (obstacle:IsA("BasePart") and obstacle)
		or obstacle.PrimaryPart
		or obstacle:FindFirstChildWhichIsA("BasePart")
	if not part then
		warn(`{obstacle} has no valid part to play a sound from`)
		return
	end

	-- Pick a specified or random sound to play
	local sound = nil :: Sound
	if custom_sound then
		sound = HitSounds:FindFirstChild(custom_sound)
	else
		sound = HitSounds[math.random(1, #HitSounds)]
	end

	-- Reject if no valid sound could be found
	if not sound then
		warn(`Sound could not be played from {obstacle}`)
		return
	end

	-- Success! Play the sound :3
	PlaySoundFromPart(part, sound)
end

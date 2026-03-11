--[[
    @Title: Damage Aura
    @Author: Joseph (BreakLoop)
    @Description: Displays a screen overlay aura effect that flashes proportionally to the damage taken by the player.
]]

local DamageAura = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local InterfaceUtilities = require(ReplicatedStorage.Interface.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("DamageAura")
local DamageAuraFrame = Interface.Frame

local current_tween = nil :: Tween
function DamageAura.take_damage(damage_taken: number, total_health: number)
	if current_tween and current_tween.PlaybackState == Enum.PlaybackState.Playing then
		current_tween.Completed:Wait()
	end
	local damage_proportion = damage_taken / total_health
	local target_aura_transparency = 1 - damage_proportion
	current_tween = TweenService:Create(
		DamageAuraFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
		{
			ImageTransparency = target_aura_transparency,
		}
	)
	current_tween:Play()
end

function DamageAura.init() end

return DamageAura

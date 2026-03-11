--[[
    @Title: Health Bar
    @Author: Joseph (BreakLoop)
    @Description: Displays and animates a vehicle health bar on the HUD, reacting to damage and healing events.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HealthBar = {}

-- Dependencies
local DamageAura = require(script.Parent.DamageAura)
local PlaySoundFromPart = require(ReplicatedStorage.Shared.Modules.Utilities.PlaySoundFromPart)
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local HealthBarFrame = Interface.HUD.HealthBar
local Player = Players.LocalPlayer
local HealingTween = TweenService:Create(
	HealthBarFrame,
	TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
	{
		Size = UDim2.fromScale(HealthBarFrame.Size.X.Scale * 1.1, HealthBarFrame.Size.X.Scale * 1.1),
	}
)
local DamageTween = TweenService:Create(
	HealthBarFrame,
	TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 1, true),
	{
		Rotation = 5,
	}
)
local DamageTween2 = TweenService:Create(
	HealthBarFrame,
	TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 1, true),
	{
		Rotation = -5,
	}
)

-- Functions

function HealthBar._update_fill(current_health: number, max_health: number)
	local tween = TweenService:Create(HealthBarFrame.Fill, TweenInfo.new(0.1), {
		Size = UDim2.fromScale(current_health / max_health, 1),
	})
	HealthBarFrame.Title.Text = `Vehicle Health: {current_health}/{max_health}`
	tween:Play()
	tween:Destroy()
end

function HealthBar._player_damaged(amount: number, total_health: number)
	if DamageTween.PlaybackState == Enum.PlaybackState.Playing then
		DamageTween.Completed:Wait()
	end
	if DamageTween2.PlaybackState == Enum.PlaybackState.Playing then
		DamageTween2.Completed:Wait()
	end
	if math.random(1, 2) == 1 then
		DamageTween:Play()
	else
		DamageTween2:Play()
	end
	DamageAura.take_damage(amount, total_health)
end

function HealthBar._player_healed(amount: number, total_health: number)
	PlaySoundFromPart(Player.Character.PrimaryPart, ReplicatedStorage.Assets.SoundEffects.Healing)
	HealingTween:Play()
end

function HealthBar._character_added(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if HealthBar._health_changed_connection then
		HealthBar._health_changed_connection:Disconnect()
	end
	local old_health = humanoid.Health
	HealthBar._health_changed_connection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		local current_health = humanoid.Health
		HealthBar._update_fill(current_health, humanoid.MaxHealth)
		-- Special cases
		-- Player has been damaged
		if current_health < old_health then
			-- If the player's current health is their maximum, then they have not actually been damaged
			if current_health == humanoid.MaxHealth then
				return
			end
			-- Get the damage dealt and process
			HealthBar._player_damaged(old_health - current_health, humanoid.MaxHealth)
		else
			-- Player has been healed
			HealthBar._player_healed(current_health - old_health, humanoid.MaxHealth)
		end
		old_health = current_health
	end)
	HealthBar._update_fill(humanoid.Health, humanoid.MaxHealth)
end

function HealthBar.set_enabled(enabled: boolean)
	HealthBar.enabled = enabled
	HealthBarFrame.Visible = enabled
	if enabled then
		local character = Player.Character or Player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		HealthBar._update_fill(humanoid.Health, humanoid.MaxHealth)
	end
end

function HealthBar.init()
	if Player.Character then
		HealthBar._character_added(Player.Character)
	end
	Player.CharacterAdded:Connect(HealthBar._character_added)
	HealthBar.set_enabled(false)
end

return HealthBar

--[[
    @Title: Obstacle Damage
    @Author: Joseph (BreakLoop)
    @Description: Deals a configurable amount of damage to the local player's humanoid when their vehicle collides with an obstacle.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local DEFAULT_DAMAGE = 30

return function(obstacle: Model | BasePart, hit: BasePart)
	-- Attributes
	local damage = obstacle:GetAttribute("Damage_Amount") or DEFAULT_DAMAGE

	-- Grab humanoid to deal damage
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid

	-- If the humanoid doesn't exist, we can't damage the character so we gotta reject
	if not humanoid then
		return
	end

	humanoid:TakeDamage(damage)
end

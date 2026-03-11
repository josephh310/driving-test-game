--[[
    @Title: Open On Touch
    @Author: Joseph (BreakLoop)
    @Description: Sets an "Activated" BoolValue to true when the local player touches the hitbox, used to trigger gate openings.
]]

local Players = game:GetService("Players")

return function(hitbox: BasePart)
	-- Get activated BoolValue
	-- This will be hooked up to the gate
	local activated_value = hitbox:FindFirstChild("Activated")

	-- If it doesn't exist, reject
	-- We will not be able to open the gate
	if not activated_value then
		warn(`Component {script.Name} {hitbox} has no activated value.`)
		return
	end

	-- Detect when the hitbox is touched
	-- Then set activated to true
	local touched_connection = hitbox.Touched:Connect(function(hit: BasePart)
		-- Check if it is a player's character touching the hitbox, if not then reject
		-- This is expected for most parts
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end

		-- Check if the player is the local player
		-- The gate should only open for one player at a time
		if player ~= Players.LocalPlayer then
			return
		end

		-- Open the gate
		activated_value.Value = true
	end)

	-- In the workspace, transparency is 0.5 for edit-time clarity
	-- We want the part to be transparent at runtime.
	hitbox.Transparency = 1

	return function()
		touched_connection:Disconnect()
	end
end

--[[
    @Title: Checkpoint Hitbox (Server)
    @Author: Joseph (BreakLoop)
    @Description: Detects when a player's vehicle reaches a checkpoint, heals the player, and advances their stage progress in the data store.
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)

return function(hitbox: BasePart)
	local touched_connection = hitbox.Touched:Connect(function(touched: BasePart)
		-- Get player from touched body part
		local player = Players:GetPlayerFromCharacter(touched.Parent)
		if not player then
			return
		end

		-- Heal the player for finishing a stage
		local character = player.Character or player.CharacterAdded:Wait()
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		humanoid.Health = humanoid.MaxHealth - 1
		humanoid.Health = humanoid.MaxHealth

		-- Check the player is in a vehicle
		if not workspace.Vehicles:FindFirstChild(player.Name) then
			return
		end
		-- Parse the ancestor folder into a stage number
		local success, stage_number = pcall(function()
			return tonumber(hitbox.Parent.Parent.Name)
		end)
		if not success then
			return
		end
		-- Set to the next stage
		DataServiceServer:set_value(player, { "current_stage" }, stage_number + 1)
		DataServiceServer:apply_change(player, { "best_stage" }, function(current_value: number)
			if current_value < stage_number + 1 then
				return stage_number + 1
			else
				return current_value
			end
		end)
	end)
	return function()
		touched_connection:Disconnect()
	end
end

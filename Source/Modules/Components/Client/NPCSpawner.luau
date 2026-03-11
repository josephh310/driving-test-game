--[[
    @Title: NPC Spawner
    @Author: Joseph (BreakLoop)
    @Description: Periodically spawns random NPC characters that walk from a start point to an end point, then despawn after reaching their destination.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCs = ReplicatedStorage.Assets.NPCs

local DEFAULT_SPAWN_DELAY = 2

return function(spawn_model: Model)
	local spawn_delay = spawn_model:GetAttribute("SpawnDelay") or DEFAULT_SPAWN_DELAY
	local start_part = spawn_model:WaitForChild("Start")
	local end_part = spawn_model:WaitForChild("End")

	local thread = task.defer(function()
		while task.wait(spawn_delay) do
			local random_npc = NPCs:GetChildren()[math.random(1, #NPCs:GetChildren())]
			local npc_clone = random_npc:Clone() :: Model

			npc_clone:AddTag("Obstacle")
			npc_clone:SetAttribute("Teleport", true)
			npc_clone.Parent = workspace.Debris
			npc_clone:MoveTo(start_part.Position)

			local humanoid = npc_clone:FindFirstChildOfClass("Humanoid") :: Humanoid
			humanoid:MoveTo(end_part.Position)

			local distance = (start_part.Position - end_part.Position).Magnitude
			local speed = humanoid.WalkSpeed
			local travel_time = distance / speed

			task.delay(travel_time, function()
				if npc_clone then
					npc_clone:Destroy()
				end
			end)
		end
	end)

	return function()
		task.cancel(thread)
	end
end

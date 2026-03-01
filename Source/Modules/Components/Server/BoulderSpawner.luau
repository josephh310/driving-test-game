local DEFAULT_SPAWN_DELAY = 3
local DEFAULT_DESPAWN_DELAY = 6
local DEFAULT_BOULDER_SIZE = Vector3.new(10, 10, 10)
local DEFAULT_BOULDER_COLOR = Color3.fromRGB(73, 73, 74)

return function(spawner: BasePart)
	local spawn_delay = spawner:GetAttribute("SpawnDelay") or DEFAULT_SPAWN_DELAY
	local despawn_delay = spawner:GetAttribute("DespawnDelay") or DEFAULT_DESPAWN_DELAY
	local boulder_size = spawner:GetAttribute("BoulderSize") or DEFAULT_BOULDER_SIZE
	local boulder_color = spawner:GetAttribute("BoulderColor") or DEFAULT_BOULDER_COLOR
	local spawner_thread = task.defer(function()
		while spawner and spawner.Parent do
			task.wait(spawn_delay)
			local boulder = Instance.new("Part")
			boulder.Size = boulder_size
			boulder.Color = boulder_color
			boulder.Shape = Enum.PartType.Ball
			boulder.Anchored = false
			boulder.Position = spawner.Position
			boulder.Parent = workspace
			boulder:AddTag("Obstacle")
			boulder:SetAttribute("SoundEffect", true)
			task.delay(despawn_delay, function()
				if boulder and boulder.Parent then
					boulder:Destroy()
				end
			end)
		end
	end)
	return function()
		task.cancel(spawner_thread)
	end
end

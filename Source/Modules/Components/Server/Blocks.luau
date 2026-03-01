local DEFAULT_RESPAWN_TIME = 5

return function(blocks: Model)
	-- Attributes
	local respawn_time = blocks:GetAttribute("RespawnTime") or DEFAULT_RESPAWN_TIME

	-- State
	local toppled = false

	-- Hitbox
	local cframe, size = blocks:GetBoundingBox()
	local hitbox = Instance.new("Part")
	hitbox.Size = size
	hitbox.CFrame = cframe
	hitbox.Anchored = true
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.Parent = blocks

	-- Collision detection
	local touched_connection = hitbox.Touched:Connect(function()
		if toppled then
			return
		end
		task.delay(respawn_time, function()
			toppled = false
		end)
	end)

	-- Destructor
	return function()
		touched_connection:Disconnect()
		hitbox:Destroy()
	end
end

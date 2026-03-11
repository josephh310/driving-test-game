--[[
    @Title: Obstacle Impulse
    @Author: Joseph (BreakLoop)
    @Description: Applies a knockback impulse to a vehicle, pushing it away from the obstacle upon collision.
]]

local IMPULSE_STRENGTH = 1000 -- Adjust as needed

return function(obstacle: Model | BasePart, hit: BasePart)
	-- Find the vehicle model from the hit part
	local vehicle = hit.Parent

	-- Find the primary part of the vehicle
	local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then
		return
	end

	-- Compute direction from obstacle to vehicle
	local obstaclePos = (obstacle:IsA("BasePart") and obstacle.Position)
		or (obstacle.PrimaryPart and obstacle.PrimaryPart.Position)
	if not obstaclePos then
		return
	end

	local vehiclePos = primaryPart.Position
	local direction = (vehiclePos - obstaclePos).Unit

	-- Apply impulse backwards (away from obstacle)
	local impulse = direction * IMPULSE_STRENGTH

	-- Use AssemblyLinearVelocity for instant impulse effect
	primaryPart.AssemblyLinearVelocity = primaryPart.AssemblyLinearVelocity + impulse
end

--[[
    @Title: Random Mover
    @Author: Joseph (BreakLoop)
    @Description: Continuously applies random angular impulses to a part, causing it to spin and tumble unpredictably.
]]

return function(part: BasePart)
	-- Attributes
	local x_power = part:GetAttribute("MovementX")
	local y_power = part:GetAttribute("MovementY")
	local z_power = part:GetAttribute("MovementZ")

	-- Movement loop
	local thread = task.defer(function()
		while task.wait() do
			local x_random = math.random(-x_power, x_power)
			local y_random = math.random(-y_power, y_power)
			local z_random = math.random(-z_power, z_power)
			part:ApplyAngularImpulse(Vector3.new(x_random, y_random, z_random))
		end
	end)

	-- Destructor
	return function()
		task.cancel(thread)
	end
end

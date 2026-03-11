--[[
    @Title: Barrier
    @Author: Joseph (BreakLoop)
    @Description: Controls a hinged barrier gate that opens and closes by observing the "Opened" attribute and adjusting the hinge target angle.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

local DEFAULT_OPEN_ANGLE = -45
local DEFAULT_CLOSED_ANGLE = 0

return function(barrier: Model)
	-- Attributes
	local open_angle = barrier:GetAttribute("OpenAngle") or DEFAULT_OPEN_ANGLE
	local closed_angle = barrier:GetAttribute("ClosedAngle") or DEFAULT_CLOSED_ANGLE

	-- MotorBox and HingeConstraint validation
	local motor_box = barrier:FindFirstChild("MotorBox")
	if not motor_box then
		warn(`Barrier {barrier.Name} is missing a MotorBox part.`)
		return
	end
	local motor_hinge = motor_box:FindFirstChildOfClass("HingeConstraint")
	if not motor_hinge then
		warn(`MotorBox in barrier {barrier.Name} is missing a HingeConstraint.`)
		return
	end

	-- State observer
	local stop_observing = Observers.observeAttribute(barrier, "Opened", function(value: boolean)
		motor_hinge.TargetAngle = value and open_angle or closed_angle
	end)

	-- Destructor
	return stop_observing
end

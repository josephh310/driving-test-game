--[[
    @Title: Moving Part
    @Author: Joseph (BreakLoop)
    @Description: Tweens a part back and forth between its original position and an offset using a looping reversing tween.
]]

local TweenService = game:GetService("TweenService")

local DEFAULT_TRANSITION_TIME = 1
local DEFAULT_DELAY_TIME = 1
local DEFAULT_POSITION_OFFSET = Vector3.new(0, 10, 0)

return function(moving: BasePart)
	-- meow
	local original_cframe = moving.CFrame

	-- Attributes
	local duration = moving:GetAttribute("Time") or DEFAULT_TRANSITION_TIME
	local delay = moving:GetAttribute("Delay") or DEFAULT_DELAY_TIME
	local offset = moving:GetAttribute("Offset") or DEFAULT_POSITION_OFFSET

	-- Tween
	local tween_info = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, delay)
	local movement_tween = TweenService:Create(moving, tween_info, { CFrame = moving.CFrame + offset })

	-- Start the tween
	movement_tween:Play()

	return function()
		movement_tween:Destroy()
		moving.CFrame = original_cframe
	end
end

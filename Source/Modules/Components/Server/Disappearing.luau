--[[
    @Title: Disappearing Part
    @Author: Joseph (BreakLoop)
    @Description: Makes a part fade out when touched by a vehicle and reappear after a delay, temporarily disabling collision.
]]

local TweenService = game:GetService("TweenService")
local DEFAULT_WAIT_TIME = 2.5
local DEFAULT_FADE_OUT_TIME = 2.5

local part_states = {
	Visible = "Visible",
	FadingOut = "FadingOut",
	Invisible = "Invisible",
	FadingIn = "FadingIn",
}

return function(disappearing_part: BasePart)
	-- State
	local state = part_states.Visible

	-- Attributes
	local fade_time = disappearing_part:GetAttribute("FadeOutTime") or DEFAULT_FADE_OUT_TIME
	local wait_time = disappearing_part:GetAttribute("WaitTime") or DEFAULT_WAIT_TIME

	-- Tweens
	local fade_tween_info = TweenInfo.new(fade_time, Enum.EasingStyle.Linear)
	local fade_out_tween = TweenService:Create(disappearing_part, fade_tween_info, { Transparency = 1 })
	local fade_in_tween = TweenService:Create(disappearing_part, fade_tween_info, { Transparency = 0 })

	-- Touch detection
	local touched_connection = disappearing_part.Touched:Connect(function(hit: BasePart)
		-- Ensure the part is visible and that the hit part belongs to a vehicle
		if state ~= part_states.Visible then
			return
		end
		if not hit:HasTag("VehicleHitbox") then
			return
		end

		-- Transition to fading out
		state = part_states.FadingOut
		fade_out_tween:Play()
		fade_out_tween.Completed:Wait()

		-- Tween completed, part is now invisible
		state = part_states.Invisible
		disappearing_part.CanCollide = false

		-- Wait for the specified time before fading back in
		task.wait(wait_time)

		-- Transition to fading in
		state = part_states.FadingIn
		disappearing_part.CanCollide = true
		fade_in_tween:Play()
		fade_in_tween.Completed:Wait()

		-- Tween completed, part is now visible again
		state = part_states.Visible
	end)

	-- Destructor
	return function()
		touched_connection:Disconnect()
	end
end

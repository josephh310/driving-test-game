local TweenService = game:GetService("TweenService")

local DEFAULT_TRANSITION_TIME = 1
local DEFAULT_DELAY_TIME = 1
local DEFAULT_POSITION_OFFSET = Vector3.new(0, 10, 0)

return function(moving: BasePart)
	-- Attributes
	local duration = moving:GetAttribute("Time") or DEFAULT_TRANSITION_TIME
	local delay = moving:GetAttribute("Delay") or DEFAULT_DELAY_TIME
	local offset = moving:GetAttribute("Offset") or DEFAULT_POSITION_OFFSET

	-- meow
	local original_position = moving.Position
	local target_position = moving.Position + offset

	-- Construct attachment for velocity
	local attachment = Instance.new("Attachment")
	attachment.Parent = moving

	-- Construct alignment objects
	local align_position = Instance.new("AlignPosition")
	align_position.Mode = Enum.PositionAlignmentMode.OneAttachment
	align_position.Attachment0 = attachment
	align_position.MaxForce = 100000
	align_position.Responsiveness = 10
	align_position.Position = moving.Position
	align_position.Parent = moving

	local align_orientation = Instance.new("AlignOrientation")
	align_orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align_orientation.Attachment0 = attachment
	align_orientation.RigidityEnabled = true
	align_orientation.CFrame = moving.CFrame
	align_orientation.Parent = moving

	-- Tweens
	local tween_info = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local out_tween = TweenService:Create(align_position, tween_info, { Position = target_position })
	local in_tween = TweenService:Create(align_position, tween_info, { Position = original_position })

	-- Tween playback loop
	local tween_thread = task.defer(function()
		while moving and moving.Parent do
			task.wait(delay)
			out_tween:Play()
			out_tween.Completed:Wait()
			task.wait(delay)
			in_tween:Play()
			in_tween.Completed:Wait()
		end
	end)

	-- Destructor
	return function()
		task.cancel(tween_thread)
		align_position:Destroy()
		align_orientation:Destroy()
		attachment:Destroy()
		out_tween:Destroy()
		in_tween:Destroy()
		moving.Position = original_position
	end
end

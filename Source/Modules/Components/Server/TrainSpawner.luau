--[[
    @Title: Train Spawner
    @Author: Joseph (BreakLoop)
    @Description: Repeatedly spawns a train at a start point and tweens it to an end point with a sound effect on each pass.
]]

local TweenService = game:GetService("TweenService")

return function(model: Model)
	-- Attributes
	local tween_delay = model:GetAttribute("SpawnDelay")
	local tween_speed = model:GetAttribute("TravelTime")

	-- Instances
	local train = model:FindFirstChild("Train")
	local spawn_start = model:FindFirstChild("Start") :: BasePart
	local spawn_end = model:FindFirstChild("End") :: BasePart

	-- Train sound effect
	local train_sound = Instance.new("Sound")
	train_sound.Parent = train.PrimaryPart
	train_sound.SoundId = "rbxassetid://78569011976103"
	train_sound.Volume = 0.25

	-- Tween
	local tween_info = TweenInfo.new(tween_speed, Enum.EasingStyle.Linear)
	local train_tween = TweenService:Create(train.PrimaryPart, tween_info, { CFrame = spawn_end.CFrame })

	-- Create thread
	local tween_thread = task.defer(function()
		while task.wait(tween_delay) do
			train:PivotTo(spawn_start.CFrame)
			train_sound:Play()
			train_tween:Play()
			train_tween.Completed:Wait()
		end
	end)

	-- Destructor
	return function()
		task.cancel(tween_thread)
		train_tween:Destroy()
	end
end

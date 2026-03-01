local RunService = game:GetService("RunService")
local DEFAULT_SPINNER_VELOCITY = Vector3.new(1, 0, 0)

return function(spinner: Model)
	local velocity = spinner:GetAttribute("Velocity") or DEFAULT_SPINNER_VELOCITY
	local rotation = CFrame.fromEulerAnglesXYZ(math.rad(velocity.X), math.rad(velocity.Y), math.rad(velocity.Z))
	local physics_connection = RunService.Stepped:Connect(function()
		spinner.PrimaryPart.CFrame = spinner.PrimaryPart.CFrame * rotation
	end)
	return function()
		physics_connection:Disconnect()
	end
end

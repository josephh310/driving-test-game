--[[
    @Title: UI Spinner
    @Author: Joseph (BreakLoop)
    @Description: Continuously rotates a UI element at a configurable speed using RenderStepped.
]]

local RunService = game:GetService("RunService")
local DEFAULT_ROTATION_SPEED = 100

return function(SpinningElement: GuiObject)
	--ATTRIBUTES
	local RotationSpeed = SpinningElement:GetAttribute("RotationSpeed") or DEFAULT_ROTATION_SPEED
	------------
	local OriginalRotation = SpinningElement.Rotation
	local RotationConnection = RunService.RenderStepped:Connect(function(dt: number)
		SpinningElement.Rotation += RotationSpeed * dt
	end)
	return function()
		RotationConnection:Disconnect()
		SpinningElement.Rotation = OriginalRotation
	end
end

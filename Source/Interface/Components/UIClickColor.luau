--[[
    @Title: UI Click Color
    @Author: Joseph (BreakLoop)
    @Description: Darkens a UI button's color on mouse-down and restores it on mouse-up using tweened animations.
]]

--Dependancies
local TweenService = game:GetService("TweenService")
local InterfaceUtils = require(script.Parent.Parent.Utilities)

--Configuration
local COLOR_MULTIPLIER = 0.6
local ANIMATION_SPEED = 0.1

--Observer function
return function(Element: GuiButton)
	local ColorProperty = InterfaceUtils.get_element_color_property(Element)
	local OriginalColor = Element[ColorProperty]
	local ColorOnHover = InterfaceUtils.multiply_color3(OriginalColor, COLOR_MULTIPLIER)
	local ColorModifyAnimation =
		TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { [ColorProperty] = ColorOnHover })
	local ColorRestoreAnimation =
		TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { [ColorProperty] = OriginalColor })
	local MouseDownConnection = Element.MouseButton1Down:Connect(function()
		ColorModifyAnimation:Play()
	end)
	local MouseUpConnection = Element.MouseButton1Up:Connect(function()
		ColorRestoreAnimation:Play()
	end)
	return function()
		ColorModifyAnimation:Destroy()
		ColorRestoreAnimation:Destroy()
		MouseDownConnection:Disconnect()
		MouseUpConnection:Disconnect()
	end
end

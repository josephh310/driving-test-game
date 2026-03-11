--[[
    @Title: UI Hover Color
    @Author: Joseph (BreakLoop)
    @Description: Darkens a UI element's color on mouse hover and restores it on mouse leave using tweened animations.
]]

-- Dependencies
local TweenService = game:GetService("TweenService")
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Configuration
local COLOR_MULTIPLIER = 0.8
local ANIMATION_SPEED = 0.1

--Observer function
return function(Element: GuiObject)
	local ColorProperty = InterfaceUtils.get_element_color_property(Element)
	local OriginalColor = Element[ColorProperty]
	local ColorOnHover = InterfaceUtils.multiply_color3(OriginalColor, COLOR_MULTIPLIER)
	local ColorModifyAnimation =
		TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { [ColorProperty] = ColorOnHover })
	local ColorRestoreAnimation =
		TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { [ColorProperty] = OriginalColor })
	local HoverConnection = Element.MouseEnter:Connect(function()
		ColorModifyAnimation:Play()
	end)
	local LeaveConnection = Element.MouseLeave:Connect(function()
		ColorRestoreAnimation:Play()
	end)
	return function()
		ColorModifyAnimation:Destroy()
		ColorRestoreAnimation:Destroy()
		HoverConnection:Disconnect()
		LeaveConnection:Disconnect()
	end
end

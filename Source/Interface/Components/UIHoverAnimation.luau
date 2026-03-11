--[[
    @Title: UI Hover Animation
    @Author: Joseph (BreakLoop)
    @Description: Scales a UI element up on mouse hover and restores it on mouse leave using tweened animations.
]]

-- Dependencies
local TweenService = game:GetService("TweenService")
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Configuration
local HOVER_SCALE = 1.05
local ANIMATION_SPEED = 0.1

-- Observer function
return function(Element: GuiObject)
	local OriginalSize = Element.Size
	local SizeOnHover = InterfaceUtils.multiply_udim_2(OriginalSize, HOVER_SCALE)
	local HoverTween = TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { Size = SizeOnHover })
	local RestoreTween = TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { Size = OriginalSize })
	local HoverConnection = Element.MouseEnter:Connect(function()
		HoverTween:Play()
	end)
	local LeaveConnection = Element.MouseLeave:Connect(function()
		RestoreTween:Play()
	end)
	return function()
		Element.Size = OriginalSize
		HoverTween:Destroy()
		RestoreTween:Destroy()
		HoverConnection:Disconnect()
		LeaveConnection:Disconnect()
	end
end

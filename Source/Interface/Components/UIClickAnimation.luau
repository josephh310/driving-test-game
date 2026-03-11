--[[
    @Title: UI Click Animation
    @Author: Joseph (BreakLoop)
    @Description: Shrinks a UI button on mouse-down and restores its size on mouse-up using tweened animations.
]]

-- Dependancies
local TweenService = game:GetService("TweenService")
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Configuration
local MOUSE_DOWN_SCALE = 0.95
local MOUSE_UP_SCALE = 1
local ANIMATION_SPEED = 0.1

-- Observer function
return function(Element: GuiButton)
	local OriginalSize = Element.Size
	local MouseDownSize = InterfaceUtils.multiply_udim_2(OriginalSize, MOUSE_DOWN_SCALE)
	local MouseUpSize = InterfaceUtils.multiply_udim_2(OriginalSize, MOUSE_UP_SCALE)
	local MouseDownAnimation = TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { Size = MouseDownSize })
	local MouseUpAnimation = TweenService:Create(Element, TweenInfo.new(ANIMATION_SPEED), { Size = MouseUpSize })
	local MouseDownConnection = Element.MouseButton1Down:Connect(function()
		MouseDownAnimation:Play()
	end)
	local MouseUpConnection = Element.MouseButton1Up:Connect(function()
		MouseUpAnimation:Play()
	end)
	return function()
		Element.Size = OriginalSize
		MouseDownAnimation:Destroy()
		MouseUpAnimation:Destroy()
		MouseDownConnection:Disconnect()
		MouseUpConnection:Disconnect()
	end
end

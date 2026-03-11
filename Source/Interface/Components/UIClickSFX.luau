--[[
    @Title: UI Click SFX
    @Author: Joseph (BreakLoop)
    @Description: Plays mouse-down and mouse-up sound effects when a UI button is clicked.
]]

-- Constants
local MouseDownSound = nil :: Sound
local MouseUpSound = nil :: Sound

-- Initialization
MouseDownSound = Instance.new("Sound")
MouseDownSound.SoundId = "rbxassetid://91297083050109"
MouseDownSound.Volume = 0.2
MouseDownSound.Parent = script

MouseUpSound = Instance.new("Sound")
MouseUpSound.SoundId = "rbxassetid://103358331161882"
MouseUpSound.Volume = 0.2
MouseUpSound.Parent = script

--Observer function
return function(Element: GuiButton)
	local MouseDownConnection = Element.MouseButton1Down:Connect(function()
		if MouseUpSound.Playing == true then
			MouseUpSound:Stop()
		end
		MouseDownSound:Play()
	end)
	local MouseUpConnection = Element.MouseButton1Up:Connect(function()
		if MouseDownSound.Playing == true then
			MouseDownSound:Stop()
		end
		MouseUpSound:Play()
	end)
	return function()
		MouseDownConnection:Disconnect()
		MouseUpConnection:Disconnect()
	end
end

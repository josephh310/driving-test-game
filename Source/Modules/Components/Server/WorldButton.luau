--[[
    @Title: World Button
    @Author: Joseph (BreakLoop)
    @Description: A physical button that executes an OnPressed callback when touched and resets after a configurable delay.
]]

local DEFAULT_UNPRESS_DELAY = 1

return function(button: Model)
	-- Attributes
	local unpress_delay = button:GetAttribute("UnpressDelay") or DEFAULT_UNPRESS_DELAY

	-- Values
	local button_part = button.PrimaryPart
	local on_pressed = button:FindFirstChild("OnPressed")

	-- Quick sanity check
	-- We need the on_pressed module to exist so the button actually does something when pressed
	if on_pressed and on_pressed:IsA("ModuleScript") then
		on_pressed = require(on_pressed)
	else
		warn(`Button {button.Name} is missing an OnPressed ModuleScript.`)
		return
	end

	-- State
	local button_down = false
	local unpressed = nil :: () -> ()

	-- Toggle function
	local function toggle_button(is_down: boolean)
		if is_down then
			button_part.Color = Color3.fromRGB(0, 255, 0)
			unpressed = on_pressed()
		else
			button_part.Color = Color3.fromRGB(255, 0, 0)
			if unpressed then
				unpressed()
			end
		end
		button_down = is_down
	end

	-- Touched connections
	local touched_connection = button_part.Touched:Connect(function(hit: BasePart)
		if button_down then
			return
		end
		toggle_button(true)
		local touch_ended
		touch_ended = button_part.TouchEnded:Connect(function(ended_hit: BasePart)
			if ended_hit ~= hit then
				return
			end
			touch_ended:Disconnect()
			task.delay(unpress_delay, toggle_button, false)
		end)
	end)

	return function()
		touched_connection:Disconnect()
	end
end

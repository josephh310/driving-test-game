--[[
    @Title: Darkness Zone
    @Author: Joseph (BreakLoop)
    @Description: Transitions the lighting to nighttime when the local player enters a zone and restores it when they leave.
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ZonePlus = require(ReplicatedStorage.Packages.ZonePlus)

return function(zone_part: BasePart)
	-- Hide the zone (is visible at edit time for clarity)
	zone_part.Transparency = 1

	-- Tweens to control the lighting
	local tween_to_day = TweenService:Create(Lighting, TweenInfo.new(1), {
		ClockTime = Lighting.ClockTime,
	})
	local tween_to_night = TweenService:Create(Lighting, TweenInfo.new(1), {
		ClockTime = 18.45,
	})

	-- Construct a new zone
	local zone = ZonePlus.new(zone_part)

	-- Detect zone entry
	local entered_connection = zone.localPlayerEntered:Connect(function()
		tween_to_night:Play()
	end)

	-- Detect the zone being exited
	local exited_connection = zone.localPlayerExited:Connect(function()
		tween_to_day:Play()
	end)

	-- Destructor
	return function()
		zone:Destroy()
		entered_connection:Disconnect()
		exited_connection:Disconnect()
	end
end

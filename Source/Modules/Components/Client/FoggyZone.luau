--[[
	@Author: Joseph (BreakLoop) 
	@Title: Foggy zone component
	@Description: Spawns fog within an area when the player enters
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ZonePlus = require(ReplicatedStorage.Packages.ZonePlus)

local DEFAULT_TRANSITION_TIME = 1
local DEFAULT_DENSITY = 0.7

local newAtmosphere = Instance.new("Atmosphere")
newAtmosphere.Density = 0
newAtmosphere.Color = Color3.new(1, 1, 1)
newAtmosphere.Decay = Color3.new(1, 1, 1)
newAtmosphere.Glare = 3
newAtmosphere.Haze = 10
newAtmosphere.Parent = Lighting

return function(zone: BasePart)
	-- Attributes, attached to zone objext
	local transitionTime = zone:GetAttribute("TransitionTime") or DEFAULT_TRANSITION_TIME
	local fogDensity = zone:GetAttribute("FogDensity") or DEFAULT_DENSITY

	-- Tweens to transition the fog in/out
	local tweenInfo = TweenInfo.new(transitionTime)
	local atmosphereFog = TweenService:Create(newAtmosphere, tweenInfo, { Density = fogDensity })
	local atmosphereDefog = TweenService:Create(newAtmosphere, tweenInfo, { Density = 0 })

	-- Construct a zone
	-- We'll use this to tell when the player is inside
	local foggyZone = ZonePlus.new(zone)

	-- Detect player enterence or exit and adjust fog levels
	local zoneEntryConnection = foggyZone.localPlayerEntered:Connect(function()
		atmosphereFog:Play()
	end)

	local zoneExitConnection = foggyZone.localPlayerExited:Connect(function()
		atmosphereDefog:Play()
	end)

	-- Destructor
	-- Called when the component is removed
	return function()
		atmosphereFog:Destroy()
		atmosphereDefog:Destroy()
		zoneEntryConnection:Disconnect()
		zoneExitConnection:Disconnect()
	end
end

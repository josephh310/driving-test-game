--[[
    @Title: Proximity Service (Client)
    @Author: 010DevX101
    @Description: Manages the lifetime of ProximityPrompts parented to characters.
]]

local ProximityServiceClient = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

local player = Players.LocalPlayer

-- Types
export type ProximityServiceClient = typeof(ProximityServiceClient)

function ProximityServiceClient.destroy_prompt(self: ProximityServiceClient, prompt_name: string)
    local vehicle = VehicleServiceUtils:wait_for_player_vehicle(player)
    local root = vehicle.PrimaryPart
    if not root or not root:IsA("BasePart") then
        warn("Vehicle root not found!")
        return
    end
    local prompt = root:WaitForChild(prompt_name)
    if not prompt then
        warn("ProximityPrompt not found in root!")
        return
    end
    prompt:Destroy()
end

function ProximityServiceClient.init(self: ProximityServiceClient)
	self.networker = Networker.client.new("ProximityService", self)
end

return ProximityServiceClient

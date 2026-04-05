--[[
    @Title: Proximity Service (Server)
    @Author: 010DevX101
    @Description: Manages the lifetime of ProximityPrompts parented to characters.
]]

local ProximityServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceServiceServer = require(ServerScriptService.Services.MarketplaceService.MarketplaceServiceServer)
local MarketplaceServiceShared = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceShared)
local Networker = require(ReplicatedStorage.Packages.Networker)
local SpawnedVehicles = workspace.Vehicles

-- Types
export type ProximityServiceServer = typeof(ProximityServiceServer)

function ProximityServiceServer._make_proximity_prompt(
    self: ProximityServiceServer,
    action: string,
    object: string,
    duration: number,
    activation_distance: number,
    on_trigger: (Player) -> (),
    part: BasePart
): ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = action
    prompt.ActionText = action
    prompt.ObjectText = object
    prompt.HoldDuration = duration
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = activation_distance
    prompt.Enabled = true
    prompt.Triggered:Connect(on_trigger)
    prompt.Parent = part
    return prompt
end

function ProximityServiceServer._make_troll_proximity_prompt(self: ProximityServiceServer, vehicle: Model)
    local player = Players:FindFirstChild(vehicle.Name) :: Player
    if not player then
        return
    end
    local character = player.Character or player.CharacterAdded:Wait()
    if not character then
        return
    end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        return
    end

    local root = vehicle.PrimaryPart
    if not root then
        return
    end

    local prompt = self:_make_proximity_prompt("Troll", "Player", 2, 15, function(playerWhoTriggered)
        MarketplaceServiceServer:prompt_purchase(playerWhoTriggered, "troll_individual", {
            type = MarketplaceServiceShared.intent_types.target,
            recipient = player
        })
    end, root)

    humanoid.Died:Connect(function()
        prompt:Destroy()
    end)

    self.networker:fire(player, "destroy_prompt", "Troll")
end

function ProximityServiceServer.init(self: ProximityServiceServer)
    self.networker = Networker.server.new("ProximityService", self)
    SpawnedVehicles.ChildAdded:Connect(function(vehicle)
        self:_make_troll_proximity_prompt(vehicle)
    end)
    for _, vehicle in SpawnedVehicles:GetChildren() do
        self:_make_troll_proximity_prompt(vehicle)
    end
end

return ProximityServiceServer
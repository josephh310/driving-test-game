--[[
    @Title: Input Service (Client)
    @Author: 010DevX101
    @Description: Manages input for the client. Particularly, it provides better controls for mobile players.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local MobileControlsGui = player_gui:WaitForChild("MobileControls")

local TouchGui = player_gui:WaitForChild("TouchGui")

local InputServiceClient = {}

export type InputServiceClient = typeof(InputServiceClient)

function InputServiceClient._enable_mobile_controls(self: InputServiceClient)
    if not MobileControlsGui or not MobileControlsGui:IsA("ScreenGui") then
        return
    end
    MobileControlsGui.Enabled = true
    if TouchGui then
        TouchGui:Destroy()
    end
end

function InputServiceClient._bind_gui_buttons_to_vehicle(self: InputServiceClient)
    local MobileFrame = MobileControlsGui:FindFirstChild("Mobile")
    if not MobileFrame or not MobileFrame:IsA("Frame") then
        return
    end
    local AccelerateButton = MobileFrame:FindFirstChild("AccelerateButton")
    local BrakeButton = MobileFrame:FindFirstChild("BrakeButton")
    if not AccelerateButton or not BrakeButton or not AccelerateButton:IsA("ImageButton") or not BrakeButton:IsA("ImageButton") then
        return
    end

    local accelerate = false
    local brake = false

    -- Accelerate Button Events
    AccelerateButton.InputBegan:Connect(function()
        accelerate = true
    end)
    AccelerateButton.InputEnded:Connect(function()
        accelerate = false
    end)

    -- Brake Button Events
    BrakeButton.InputBegan:Connect(function()
        brake = true
    end)
    BrakeButton.InputEnded:Connect(function()
        brake = false
    end)

    RunService.RenderStepped:Connect(function()
        if not accelerate and not brake then
            VehicleServiceClient:set_throttle_float(0)
        elseif accelerate then
            VehicleServiceClient:set_throttle_float(1)
        elseif brake then
            VehicleServiceClient:set_throttle_float(-1)
        end
        
        local vehicle_root = VehicleServiceUtils:get_vehicle_from_player(player).PrimaryPart
        if not vehicle_root then
            return
        end

        local camera_look = camera.CFrame.LookVector
        local vehicle_right = vehicle_root.CFrame.RightVector
        local steer_float = camera_look:Dot(vehicle_right)
        VehicleServiceClient:set_steer_float(steer_float)
    end)
end

function InputServiceClient.init(self: InputServiceClient)
    if not UserInputService.TouchEnabled then
        return
    end
    self:_enable_mobile_controls()
    VehicleServiceUtils:wait_for_player_vehicle(player)
    self:_bind_gui_buttons_to_vehicle()
end

return InputServiceClient

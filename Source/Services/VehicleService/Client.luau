--[[
	@Title: VehicleService Client
    @Author: 010DevX101
	@Description: Handles the vehicle system on the client
]]

local VehicleServiceClient = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HealthBar = require(ReplicatedStorage.Interface.GameHUD.HealthBar)
local VehicleServiceUtils = require(script.Parent.VehicleServiceUtils)
local VehicleTypes = require(script.Parent.VehicleTypes)
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local EngineClient = require(ReplicatedStorage.Shared.Services.VehicleService.Components.Engine.EngineClient)
local HornClient = require(ReplicatedStorage.Shared.Services.VehicleService.Components.Horn.HornClient)

-- Variables
local Player = Players.LocalPlayer
local Cleanup = {}

-- Types
type VehicleServiceClient = typeof(VehicleServiceClient)

-- Public functions
function VehicleServiceClient.cleanup()
	for _, fn in Cleanup do
		fn()
	end
	HealthBar.set_enabled(false)
end

function VehicleServiceClient._force_sit(self: VehicleServiceClient)
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	return function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

function VehicleServiceClient._setup_components(self: VehicleServiceClient, vehicle_name: string, spawned_model: Model)
	-- Fetch the vehicle configuration from VehicleTypes
	local vehicle_data = VehicleTypes[vehicle_name] :: VehicleTypes.VehicleData
	if not vehicle_data then
		warn(`No vehicle data exists for vehicle with name {vehicle_name}.`)
		return
	end

	-- Load relevent components
	if vehicle_data.components.horn then
		Cleanup[#Cleanup + 1] = HornClient.init()
	end

	if vehicle_data.components.engine then
		local vehicle_constraints = spawned_model.Scripted.Constraints
		local vehicle_chassis = spawned_model.Scripted.Chassis
		local vehicle_platform = vehicle_chassis.Platform
		Cleanup[#Cleanup + 1] =
			EngineClient.init(spawned_model.Scripted.VehicleSeat, vehicle_constraints:GetChildren(), {
				vehicle_platform.AttachmentFL,
				vehicle_platform.AttachmentFR,
			}, vehicle_data.components.engine.max_steer_angle)
	end
end

function VehicleServiceClient.reset_vehicle_position(self: VehicleServiceClient)
	local vehicle = VehicleServiceUtils:get_vehicle_from_player(Player) :: Model
	if not vehicle then
		return
	end
	local current_stage = DataServiceClient.get_data().current_stage
	local new_cframe = VehicleServiceUtils:get_spawn_cframe_for_stage(current_stage)
	vehicle:PivotTo(new_cframe)
end

function VehicleServiceClient.setup_vehicle(self: VehicleServiceClient, vehicle_name: string)
	-- Sit the player and disable jumping
	-- Returns a function to allow the player to jump again, add to cleanup to call it when a player's vehicle is removed
	local jump_again = self:_force_sit()
	Cleanup[#Cleanup + 1] = jump_again

	-- Wait for the model to fully replicate
	local spawned_model = workspace.Vehicles:WaitForChild(Player.Name)

	-- Set up the component
	self:_setup_components(vehicle_name, spawned_model)

	-- Enable teh health bar
	HealthBar.set_enabled(true)
end

function VehicleServiceClient.init(self: VehicleServiceClient)
	self.networker = Networker.client.new("VehicleService", self)
end

return VehicleServiceClient

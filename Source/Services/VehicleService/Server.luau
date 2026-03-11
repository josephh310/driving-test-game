--[[
	@Title: VehicleService Server
    @Author: 010DevX101
	@Description: Handles the vehicle system on the server
]]

local VehicleServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TextService = game:GetService("TextService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)
local VehicleTypes = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleTypes)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local HornServer = require(ServerScriptService.Services.VehicleService.Components.Horn.HornServer)

local SpawnedVehicles = workspace.Vehicles
local Cleanup = {}

-- Types
export type VehicleServiceServer = typeof(VehicleServiceServer)

-- Internal functions
function VehicleServiceServer._cleanup(self: VehicleServiceServer, player: Player)
	for _, fn in Cleanup[player] do
		fn()
	end
end

function VehicleServiceServer._spawn_vehicle_model(
	self: VehicleServiceServer,
	player: Player,
	vehicle_model: Model,
	cframe: CFrame?
): Model?
	-- Get the height of the vehicle model
	local _, size = vehicle_model:GetBoundingBox()
	local model_height = size.Y / 2

	-- Get the CFrame of where the vehicle will be spawned
	local player_character = player.Character or player.CharacterAdded:Wait()
	local new_vehicle_cframe = (cframe or player_character.PrimaryPart.CFrame) + Vector3.new(0, model_height, 0)

	-- Create the new vehicle
	local new_vehicle_model = vehicle_model:Clone()
	new_vehicle_model.Name = player.Name
	new_vehicle_model.Parent = SpawnedVehicles

	-- Pivot to the decided cframe
	new_vehicle_model:PivotTo(new_vehicle_cframe)

	-- Set the network owner of the vehicle to the player
	-- so the player can control the vehicle's physical constraints
	if new_vehicle_model.PrimaryPart then
		new_vehicle_model.PrimaryPart:SetNetworkOwner(player)
	end

	return new_vehicle_model
end

function VehicleServiceServer._force_sit(self: VehicleServiceServer, player: Player, vehicle_model: Model)
	-- Get the vehicle's seat
	local vehicle_seat = vehicle_model.Scripted:FindFirstChildWhichIsA("VehicleSeat")
	if not vehicle_seat then
		warn("Vehicle model is missing VehicleSeat!")
		return
	end

	-- Get the player's humanoid
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	-- Force the player to sit in the vehicle seat
	if vehicle_seat.Occupant ~= humanoid then
		vehicle_seat:Sit(humanoid)
	end
end

function VehicleServiceServer._setup_components(
	self: VehicleServiceServer,
	player: Player,
	spawned_model: Model,
	vehicle_name: string
)
	-- Load vehicle data for vehicle
	local vehicle_data = VehicleTypes[vehicle_name] :: VehicleTypes.VehicleData
	if not vehicle_data then
		warn(`No vehicle data for vehicle with name {vehicle_name}.`)
		return
	end

	-- Load relevent components
	if vehicle_data.components.horn then
		Cleanup[player][#Cleanup[player] + 1] =
			HornServer.init(player, spawned_model, vehicle_data.components.horn.sound)
	end
end

function VehicleServiceServer._setup_collisions(self: VehicleServiceServer, spawned_vehicle: Model)
	-- Get the vehicle's body
	local body = spawned_vehicle:FindFirstChild("Body")
	if not body then
		warn(`{spawned_vehicle} does not have a body.`)
		return
	end

	-- Fetch hitbox dimensions
	local cframe, size = spawned_vehicle:GetBoundingBox()

	-- Create a new vehicle hitbox
	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = size * 1.01
	hitbox.CFrame = cframe
	hitbox.CanCollide = false
	hitbox.Transparency = 1
	hitbox.Massless = true
	hitbox.Parent = spawned_vehicle

	-- Weld the hitbox to the vehicle
	local hitbox_weld = Instance.new("WeldConstraint")
	hitbox_weld.Part0 = hitbox
	hitbox_weld.Part1 = spawned_vehicle.PrimaryPart
	hitbox_weld.Parent = hitbox

	-- Add a hitbox tag
	hitbox:AddTag("VehicleHitbox")

	return hitbox
end

function VehicleServiceServer._set_plate(self: VehicleServiceServer, player: Player, vehicle_model: Model, text: string)
	local license_plate = vehicle_model:FindFirstChild("NumberPlate")
	if not license_plate or not license_plate:IsA("Model") then
		warn("Vehicle does not have a license plate!")
		return
	end
	local base = license_plate:FindFirstChild("Base")
	if not base or not base:IsA("BasePart") then
		warn("License plate does not have a base!")
		return
	end
	local plate_text = base:FindFirstChild("SurfaceGui"):FindFirstChild("PlateText")
	if not plate_text or not plate_text:IsA("TextLabel") then
		return
	end
	plate_text.Text = text
end

function VehicleServiceServer._customise_color(
	self: VehicleServiceServer,
	player: Player,
	vehicle_model: Model,
	color: Color3
)
	for _, colorable_part in vehicle_model:QueryDescendants("BasePart.Colorable") do
		colorable_part = colorable_part :: BasePart
		colorable_part.Color = color
	end
end

function VehicleServiceServer._spawn_vehicle_at_stage(self: VehicleServiceServer, player: Player, stage: number)
	-- Player should not have a vehicle at stage 0 (the intro)
	if stage == 0 then
		return
	end

	-- Get a free position to spawn the vehicle at
	local selected_spawn_cframe = VehicleServiceUtils:get_spawn_cframe_for_stage(stage)

	-- Spawn at the selected spawn's CFrame
	self:_spawn_vehicle(player, selected_spawn_cframe)
end

function VehicleServiceServer._destroy_vehicle(self: VehicleServiceServer, player: Player, vehicle_model: Model?)
	-- Get the vehicle model if not provided to the function
	vehicle_model = vehicle_model or SpawnedVehicles:FindFirstChild(player.Name)
	if not vehicle_model or not vehicle_model:IsA("Model") then
		return
	end

	-- Destroy the vehicle and call cleanup functions
	vehicle_model:Destroy()
	self.networker:fire(player, "cleanup")
	self:_cleanup(player)
end

function VehicleServiceServer._spawn_vehicle(
	self: VehicleServiceServer,
	player: Player,
	cframe: CFrame,
	vehicle: string?
)
	-- Grab currently equipped vehicle
	local equipped_vehicle = vehicle or DataServiceServer:get_value(player, { "equipped_vehicle" })

	-- If there is already a vehicle spawned by the player, destroy it
	local spawned_vehicle = SpawnedVehicles:FindFirstChild(player.Name)
	if spawned_vehicle and spawned_vehicle:IsA("Model") then
		self:_destroy_vehicle(player, spawned_vehicle)
	end

	-- Get vehicle-specific data
	local vehicle_data = VehicleTypes[equipped_vehicle] :: VehicleTypes.VehicleData
	if not vehicle_data then
		error(`Vehicle data for vehicle {equipped_vehicle} does not exist.`)
	end

	-- Get vehicle model from vehicle data
	local vehicle_model = vehicle_data.data.vehicle_model

	-- Spawn new vehicle
	local new_vehicle, reason = self:_spawn_vehicle_model(player, vehicle_model, cframe)
	if not new_vehicle then
		error(`Unable to spawn vehicle for {player.Name} - {reason}`)
		return
	end

	-- Set the player's license plate
	local plate = DataServiceServer:get_value(player, { "plate" })
	if plate ~= nil then
		self:_set_plate(player, new_vehicle, plate)
	end

	-- Set the player's vehicle color
	local vehicles = DataServiceServer:get_value(player, { "vehicles" })
	local color_data: { r: number, g: number, b: number }? = vehicles[equipped_vehicle].color
	if color_data then
		self:_customise_color(player, new_vehicle, Color3.fromRGB(color_data.r, color_data.g, color_data.b))
	end

	-- Grab the player's humanoid
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end

	-- Set the player's humanoid to the configured vehicle health
	humanoid.MaxHealth = vehicle_data.data.health
	humanoid.Health = vehicle_data.data.health

	-- Detect when the player dies and clean up their vehicle
	humanoid.Died:Connect(function()
		self:_destroy_vehicle(player, new_vehicle)
	end)

	-- Initialize the vehicle
	self:_setup_components(player, new_vehicle, equipped_vehicle)
	self:_setup_collisions(new_vehicle)
	self:_force_sit(player, new_vehicle)

	-- Notify the player
	self.networker:fire(player, "setup_vehicle", equipped_vehicle)
end

-- Public functions
function VehicleServiceServer.request_customise_color(
	self: VehicleServiceServer,
	player: Player,
	vehicle_name: string,
	color: Color3
)
	if typeof(color) ~= "Color3" or typeof(vehicle_name) ~= "string" then
		return
	end
	local products = DataServiceServer:get_value(player, { "products_owned" })
	if not table.find(products, "color_customisation") then
		warn(`User {player.Name} does not own color customisation gamepass!`)
		return
	end
	local vehicles = DataServiceServer:get_value(player, { "vehicles" })
	local vehicle = vehicles[vehicle_name]
	if not vehicle then
		warn(`User does not own vehicle {vehicle_name}!`)
		return
	end
	DataServiceServer:apply_change(player, { "vehicles" }, function(current)
		current[vehicle_name] = {
			color = {
				r = color.R * 255,
				g = color.G * 255,
				b = color.B * 255,
			},
		}
		return current
	end)
	local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
	if vehicle_model and vehicle_model:IsA("Model") then
		self:_customise_color(player, vehicle_model, color)
	end
end

function VehicleServiceServer.request_set_plate(self: VehicleServiceServer, player: Player, original_text: string)
	local function save_and_set_plate(filtered: string)
		print("setting to " .. filtered)
		DataServiceServer:set_value(player, { "plate" }, filtered)
		local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
		if vehicle_model and vehicle_model:IsA("Model") then
			self:_set_plate(player, vehicle_model, filtered)
		end
	end
	if typeof(original_text) ~= "string" then
		return
	end
	local text: string
	local MAX_PLATE_LENGTH = 8
	local products = DataServiceServer:get_value(player, { "products_owned" })
	if not table.find(products, "plate_customisation") then
		warn(`User {player.Name} does not own plate customisation gamepass!`)
		return
	end
	if text == "" then
		save_and_set_plate(text)
		return
	end
	text = string.upper(string.sub(original_text, 1, MAX_PLATE_LENGTH))
	local success, result = pcall(function()
		return TextService:FilterStringAsync(text, player.UserId)
	end)
	if not success then
		warn(`Failed to filter text: {result}`)
		return
	end
	text = result:GetNonChatStringForBroadcastAsync()
	save_and_set_plate(text)
end

function VehicleServiceServer.request_equip_vehicle(
	self: VehicleServiceServer,
	player: Player,
	vehicle_name: string
): string
	local SUCCESS_MESSAGE = `Successfully equipped vehicle {vehicle_name}!`
	local owned_vehicles = DataServiceServer:get_value(player, { "vehicles" })
	if not owned_vehicles then
		return `Error fetching {player.Name}'s owned vehicles.`
	end
	if not owned_vehicles[vehicle_name] then
		return "You don't own this vehicle!"
	end
	DataServiceServer:set_value(player, { "equipped_vehicle" }, vehicle_name)
	if SpawnedVehicles:FindFirstChild(player.Name) then
		self:reset_vehicle(player, true)
		return SUCCESS_MESSAGE
	end
	local stage = DataServiceServer:get_value(player, { "current_stage" })
	self:_spawn_vehicle_at_stage(player, stage)
	return SUCCESS_MESSAGE
end

function VehicleServiceServer.reset_vehicle(self: VehicleServiceServer, player: Player, hard_reset: boolean)
	-- Get the player's vehicle model
	local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
	if not vehicle_model or not vehicle_model:IsA("Model") then
		return
	end

	-- Get the player's current stage
	local stage = DataServiceServer:get_value(player, { "current_stage" })

	-- Completely regenerate the vehicle if hard_reset is true
	-- Else teleport back to the start of the stage
	if hard_reset == true then
		self:_destroy_vehicle(player, vehicle_model)
		player:LoadCharacterAsync()
		self:_spawn_vehicle_at_stage(player, stage)
	else
		local _, vehicle_size = vehicle_model:GetBoundingBox()
		local spawn_offset = vehicle_size.Y / 2
		local free_spawn_cframe = self:_get_spawn_cframe_for_stage(stage)
		vehicle_model:PivotTo(free_spawn_cframe + Vector3.new(0, spawn_offset, 0))
	end
end

function VehicleServiceServer.init(self: VehicleServiceServer)
	self.networker = Networker.server.new("VehicleService", self, {
		self.request_equip_vehicle,
		self.reset_vehicle,
		self.request_set_plate,
		self.request_customise_color,
	})

	local function player_added(player: Player)
		Cleanup[player] = {}
		player.CharacterAdded:Connect(function()
			local equipped_vehicle = DataServiceServer:get_value(player, { "equipped_vehicle" })
			local stage = DataServiceServer:get_value(player, { "current_stage" })
			if VehicleTypes[equipped_vehicle] ~= nil then
				self:_spawn_vehicle_at_stage(player, stage)
			end
		end)
	end

	-- Vehicle removal logic
	Players.PlayerRemoving:Connect(function(player)
		local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
		if vehicle_model then
			self:_destroy_vehicle(player, vehicle_model)
		end
		self:_cleanup(player)
		Cleanup[player] = nil
	end)

	-- Vehicle spawning logic
	Players.PlayerAdded:Connect(player_added)
	for _, player in Players:GetPlayers() do
		player_added(player)
	end
end

return VehicleServiceServer

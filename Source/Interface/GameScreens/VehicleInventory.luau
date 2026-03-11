--[[
    @Title: Vehicle Inventory
    @Author: Joseph (BreakLoop)
    @Description: Displays the player's vehicle inventory, allowing them to equip vehicles and access customisation options.
]]

local VehicleInventory = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local DataServiceShared = require(ReplicatedStorage.Shared.Services.DataService.DataServiceShared)
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local VehicleTypes = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleTypes)
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local InterfaceAssets = ReplicatedStorage.Assets.Interface
local VehicleInventoryFrame = Interface.Screens.VehicleInventory
local FrameCloseButton = VehicleInventoryFrame.Topbar.Close
local InventoryTrove = Trove.new()

-- Functions
function VehicleInventory.hide()
	VehicleInventoryFrame.Visible = false
end

function VehicleInventory.show()
	VehicleInventoryFrame.Visible = true
end

function VehicleInventory._close_button_clicked()
	InterfaceUtils.toggle_screen("VehicleInventory")
end

function VehicleInventory._plate_customise_clicked()
	local products_owned = DataServiceClient.get_data().products_owned
	if table.find(products_owned, "plate_customisation") then
		InterfaceUtils.toggle_screen("PlateCustomise")
	else
		MarketplaceServiceClient:purchase_product("plate_customisation")
	end
end

function VehicleInventory._customise_vehicle_clicked(vehicle_name: string)
	local products_owned = DataServiceClient.get_data().products_owned
	if table.find(products_owned, "color_customisation") then
		InterfaceUtils.toggle_screen("ColorCustomise", vehicle_name)
	else
		MarketplaceServiceClient:purchase_product("color_customisation")
	end
end

function VehicleInventory.refresh(vehicle_equipped: string, vehicles: DataServiceShared.Vehicles)
	-- Remove old instances, connections, etc
	InventoryTrove:Clean()
	-- Spawn new
	for vehicle_index, vehicle_data in VehicleTypes do
		if vehicle_equipped == vehicle_index then -- This vehicle is the one equipped
			local equipped_tile = InventoryTrove:Clone(InterfaceAssets.CarTileEquipped)
			equipped_tile.VehicleName.Text = vehicle_data.data.display_name
			equipped_tile.Parent = VehicleInventoryFrame.Content
			InventoryTrove:Connect(equipped_tile.Buttons.CustomiseButton.MouseButton1Click, function()
				VehicleInventory._customise_vehicle_clicked(vehicle_index)
			end)
		elseif vehicles[vehicle_index] then -- This vehicle is owned
			local owned_tile = InventoryTrove:Clone(InterfaceAssets.CarTileOwned)
			owned_tile.VehicleName.Text = vehicle_data.data.display_name
			owned_tile.Parent = VehicleInventoryFrame.Content
			InventoryTrove:Connect(owned_tile.Buttons.EquipButton.MouseButton1Click, function()
				VehicleServiceClient.networker:fire("request_equip_vehicle", vehicle_index)
				VehicleInventory._close_button_clicked()
			end)
			InventoryTrove:Connect(owned_tile.Buttons.CustomiseButton.MouseButton1Click, function()
				VehicleInventory._customise_vehicle_clicked(vehicle_index)
			end)
		else -- This vehicle is unowned
			local unowned_tile = InventoryTrove:Clone(InterfaceAssets.CarTileUnowned)
			unowned_tile.VehicleName.Text = vehicle_data.data.display_name
			unowned_tile.Parent = VehicleInventoryFrame.Content
		end
	end
end

function VehicleInventory.init()
	-- Listen to inventory or equipped vehicle refreshing
	DataServiceClient.connect_to_value_changed({ "vehicles" }, function(vehicles)
		local equipped_vehicle = DataServiceClient:get_data().equipped_vehicle
		VehicleInventory.refresh(equipped_vehicle, vehicles)
	end)
	DataServiceClient.connect_to_value_changed({ "equipped_vehicle" }, function(equipped_vehicle)
		local vehicles = DataServiceClient:get_data().vehicles
		VehicleInventory.refresh(equipped_vehicle, vehicles)
	end)
	--Button connections
	FrameCloseButton.MouseButton1Click:Connect(VehicleInventory._close_button_clicked)
	VehicleInventoryFrame.EditPlate.MouseButton1Click:Connect(VehicleInventory._plate_customise_clicked)
end

return VehicleInventory

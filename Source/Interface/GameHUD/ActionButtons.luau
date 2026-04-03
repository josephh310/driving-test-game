--[[
    @Title: Action Buttons
    @Author: Joseph (BreakLoop)
    @Description: Handles HUD action buttons for resetting the vehicle and toggling the troll shop.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActionButtons = {}

-- Dependencies
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local ActionButtonsFrame = Interface.HUD.ActionButtons

--Functions
function ActionButtons._reset_vehicle_clicked()
	VehicleServiceClient.reset_vehicle_position()
end

function ActionButtons._troll_clicked()
	-- Toggle troll shop
	InterfaceUtilities.toggle_screen("TrollShop")
end

function ActionButtons.init()
	ActionButtonsFrame.ResetVehicle.MouseButton1Click:Connect(ActionButtons._reset_vehicle_clicked)
	ActionButtonsFrame.TrollButton.MouseButton1Click:Connect(ActionButtons._troll_clicked)
end

return ActionButtons

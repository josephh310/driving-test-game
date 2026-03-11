--[[
    @Title: Plate Customise
    @Author: Joseph (BreakLoop)
    @Description: Allows players to enter and submit custom text for their vehicle license plate.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlateCustomise = {}

-- Dependencies
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local PlateCustomiseFrame = Interface.Screens.PlateCustomise
local FrameCloseButton = PlateCustomiseFrame.Topbar.Close

-- Functions
function PlateCustomise.hide()
	PlateCustomiseFrame.Visible = false
end

function PlateCustomise.show(vehicle_name: string?)
	PlateCustomiseFrame.Visible = true
end

function PlateCustomise._close_button_clicked()
	InterfaceUtils.toggle_screen("PlateCustomise")
end

function PlateCustomise._confirm_button_clicked()
	VehicleServiceClient.networker:fire("request_set_plate", PlateCustomiseFrame.Input.TextBox.Text)
end

function PlateCustomise.init()
	FrameCloseButton.MouseButton1Click:Connect(PlateCustomise._close_button_clicked)
	PlateCustomiseFrame.Confirm.MouseButton1Click:Connect(PlateCustomise._confirm_button_clicked)
end

return PlateCustomise

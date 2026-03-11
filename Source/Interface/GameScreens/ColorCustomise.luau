--[[
    @Title: Color Customise
    @Author: Joseph (BreakLoop)
    @Description: Provides an HSV color wheel and brightness slider for players to pick and apply custom vehicle colors.
]]

local ColorCustomise = {
	selected_color = nil :: Color3,
	selected_brightness = nil :: number,
	resulting_color = nil :: Color3,
}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HSVColorWheel = require(ReplicatedStorage.Shared.Modules.Utilities.HSVColorWheel)
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local ColorCustomiseFrame = Interface.Screens.ColorCustomise
local ColorWheelFrame = ColorCustomiseFrame.Selection.ColorWheel
local BrightnessFrame = ColorCustomiseFrame.Selection.BrightnessBar
local ColorSelector = ColorWheelFrame.Selector
local BrightnessSelector = BrightnessFrame.Selector
local FrameCloseButton = ColorCustomiseFrame.Topbar.Close

-- Functions
function ColorCustomise.hide()
	ColorCustomiseFrame.Visible = false
end

function ColorCustomise.show(vehicle_name: string)
	if vehicle_name then
		ColorCustomise.vehicle = vehicle_name
	end
	ColorCustomiseFrame.Visible = true
end

function ColorCustomise._close_button_clicked()
	InterfaceUtils.toggle_screen("ColorCustomise")
end

function ColorCustomise._render_color_preview()
	-- Fetch + normalise color state
	local color = ColorCustomise.selected_color
	local brightness = math.clamp(ColorCustomise.selected_brightness, 0, 1)
	-- Calculate resulting color and render preview
	ColorCustomise.resulting_color = InterfaceUtils.multiply_color3(color, brightness)
	ColorCustomiseFrame.SelectedColour.BackgroundColor3 = ColorCustomise.resulting_color
end

function ColorCustomise._limit_color_selector(current_position: UDim2)
	local circle_radius = 0.5
	local x_position = current_position.X.Scale - 0.5
	local y_position = current_position.Y.Scale - 0.5
	local offset = math.sqrt(x_position ^ 2 + y_position ^ 2)
	if offset <= circle_radius then
		ColorCustomise.last_position = current_position
		return current_position
	else
		return ColorCustomise.last_position
	end
end

function ColorCustomise._confirm_clicked()
	local color = ColorCustomiseFrame.SelectedColour.BackgroundColor3
	if ColorCustomise.vehicle then
		VehicleServiceClient.networker:fire("request_customise_color", ColorCustomise.vehicle, color)
		ColorCustomise._close_button_clicked()
	end
end

function ColorCustomise.init()
	-- Create and render the HSV color wheel
	local color_wheel_editable = HSVColorWheel.create_wheel_editableimage(1024)
	local color_wheel_content = Content.fromObject(color_wheel_editable)
	ColorWheelFrame.ColourWheel.ImageContent = color_wheel_content

	-- Create drag detector for the color selector
	local color_drag_detector = Instance.new("UIDragDetector")
	color_drag_detector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Scale
	color_drag_detector.Parent = ColorSelector
	color_drag_detector:AddConstraintFunction(1, ColorCustomise._limit_color_selector)

	-- Detect drag detector position change and fetch the color from the pixel buffer
	-- Render to the color preview
	color_drag_detector:AddConstraintFunction(2, function(position: UDim2)
		ColorCustomise.selected_color = HSVColorWheel.get_color_at_position(color_wheel_editable, position)
		ColorCustomise._render_color_preview()
	end)

	-- Create drag detector for the brightness selector
	local brightness_drag_detector = Instance.new("UIDragDetector")
	brightness_drag_detector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
	brightness_drag_detector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Scale
	brightness_drag_detector.DragAxis = Vector2.new(0, 1)
	brightness_drag_detector.BoundingUI = BrightnessFrame
	brightness_drag_detector.Parent = BrightnessSelector

	-- Detect drag detector position changes
	-- Use relative scale position to decide brightness
	brightness_drag_detector:AddConstraintFunction(1, function(position: UDim2)
		ColorCustomise.selected_brightness = (1 - position.Y.Scale)
		ColorCustomise._render_color_preview()
	end)

	-- Set constants
	ColorCustomise.selected_color = HSVColorWheel.get_color_at_position(color_wheel_editable, ColorSelector.Position)
	ColorCustomise.selected_brightness = (1 - BrightnessSelector.Position.Y.Scale)
	ColorCustomise._render_color_preview()

	-- Button connections
	FrameCloseButton.MouseButton1Click:Connect(ColorCustomise._close_button_clicked)
	ColorCustomiseFrame.Confirm.MouseButton1Click:Connect(ColorCustomise._confirm_clicked)
end

return ColorCustomise

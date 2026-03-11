--[[
    @Title: Game Shop
    @Author: Joseph (BreakLoop)
    @Description: Renders the in-game shop screen with gamepass listings and skip purchase options, supporting buy and gift actions.
]]

local GameShop = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local GameShopFrame = Interface.Screens.GameShop
local GameShopContent = GameShopFrame.Shop.ScrollingFrame
local FrameCloseButton = GameShopFrame.Topbar.Close

-- Functions
function GameShop.hide()
	GameShopFrame.Visible = false
	GameShopFrame.Shop.ScrollingFrame.CanvasPosition = Vector2.zero
end

function GameShop.show(scroll_progress: number) -- 0 -> 1
	if scroll_progress then
		local absolute_canvas_y = GameShopFrame.Shop.ScrollingFrame.AbsoluteCanvasSize.Y
		local absolute_y_size = GameShopFrame.Shop.ScrollingFrame.AbsoluteSize.Y
		local y_scroll_position = (absolute_canvas_y - absolute_y_size) * scroll_progress
		TweenService:Create(GameShopFrame.Shop.ScrollingFrame, TweenInfo.new(0.25), {
			CanvasPosition = Vector2.new(0, y_scroll_position),
		}):Play()
	end
	GameShopFrame.Visible = true
end

function GameShop._close_button_clicked()
	InterfaceUtils.toggle_screen("GameShop")
end

function GameShop._load_gamepass_frame(pass_name: string, pass_frame: Frame)
	local pass_info = MarketplaceServiceClient:get_product_data(pass_name)
	pass_frame.Buttons.Buy.Price.Text = pass_info.PriceInRobux
	pass_frame.GamepassImage.Image = `rbxassetid://{pass_info.IconImageAssetId}`
	pass_frame.Title.Text = string.upper(pass_info.DisplayName)
	pass_frame.Buttons.Buy.MouseButton1Click:Connect(function()
		MarketplaceServiceClient:purchase_product(pass_name)
		InterfaceUtils.toggle_screen("GameShop")
	end)
	pass_frame.Buttons.Gift.MouseButton1Click:Connect(function()
		InterfaceUtils.toggle_screen("GiftScreen", pass_name)
	end)
	DataServiceClient.connect_to_value_changed({ "products_owned" }, function(new_products)
		if table.find(new_products, pass_name) then
			pass_frame.Buttons.Buy.Visible = false
		end
	end)
end

function GameShop._load_purchase_buttons(pass_name: string, robux_frame: Frame)
	local pass_info = MarketplaceServiceClient:get_product_data(pass_name)
	robux_frame.Buy.Price.Text = pass_info.PriceInRobux
	robux_frame.Buy.MouseButton1Click:Connect(function()
		MarketplaceServiceClient:purchase_product(pass_name)
		InterfaceUtils.toggle_screen("GameShop")
	end)
	robux_frame.Gift.MouseButton1Click:Connect(function()
		InterfaceUtils.toggle_screen("GiftScreen", pass_name)
	end)
end

function GameShop.init()
	-- Gamepasses
	task.defer(GameShop._load_gamepass_frame, "exclusive_vehicles", GameShopContent.Passes.ExclusiveVehicle)
	task.defer(GameShop._load_gamepass_frame, "plate_customisation", GameShopContent.Passes.PlateCustomise)
	task.defer(GameShop._load_gamepass_frame, "color_customisation", GameShopContent.Passes.ColorCustomise)
	task.defer(GameShop._load_gamepass_frame, "speed_boost", GameShopContent.Passes.SpeedBoost)

	-- Skips
	task.defer(GameShop._load_purchase_buttons, "skip_1", GameShopContent.Skips.Content.Buttons.Skip1)
	task.defer(GameShop._load_purchase_buttons, "skip_5", GameShopContent.Skips.Content.Buttons.Skip5)
	task.defer(GameShop._load_purchase_buttons, "skip_10", GameShopContent.Skips.Content.Buttons.Skip10)
	task.defer(GameShop._load_purchase_buttons, "skip_30", GameShopContent.Skips.Content.Buttons.Skip30)

	-- Button connections
	FrameCloseButton.MouseButton1Click:Connect(GameShop._close_button_clicked)
end

return GameShop

--[[
    @Title: Starter Pack Popup
    @Author: Joseph (BreakLoop)
    @Description: Manages the starter pack popup screen, allowing players to purchase or gift the starter pack.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPack = {}

-- Dependancies
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local StarterPackFrame = Interface.Screens.StarterPackPopup.StarterPack

-- Functions
function StarterPack.hide()
	StarterPackFrame.Parent.Visible = false
end

function StarterPack.show()
	StarterPackFrame.Parent.Visible = true
end

function StarterPack._close_button_clicked()
	InterfaceUtilities.toggle_screen("StarterPackPopup")
end

function StarterPack._buy_button_clicked()
	MarketplaceServiceClient:purchase_product("starter_pack")
	StarterPack:_close_button_clicked()
end

function StarterPack._gift_button_clicked()
	InterfaceUtilities.toggle_screen("GiftScreen", "starter_pack")
end

function StarterPack.init()
	-- Properties
	StarterPack.hide_ui_when_open = false

	-- Load pricing
	task.defer(function()
		local starter_pack_data = MarketplaceServiceClient:get_product_data("starter_pack")
		StarterPackFrame.Content.Buttons.Buy.Price.Text = starter_pack_data.PriceInRobux
	end)

	-- Connections
	StarterPackFrame.Background.Topbar.Close.MouseButton1Click:Connect(StarterPack._close_button_clicked)
	StarterPackFrame.Content.Buttons.Buy.MouseButton1Click:Connect(StarterPack._buy_button_clicked)
	StarterPackFrame.Content.Buttons.Gift.MouseButton1Click:Connect(StarterPack._gift_button_clicked)
end

return StarterPack

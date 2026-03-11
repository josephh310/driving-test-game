--[[
    @Title: Grid Buttons
    @Author: Joseph (BreakLoop)
    @Description: Manages the HUD button grid for opening the shop, inventory, and using or purchasing skips.
]]

local GridButtons = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local SkipServiceClient = require(ReplicatedStorage.Shared.Services.SkipService.SkipServiceClient)
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local GridButtonsFrame = Interface.HUD.ButtonGrid
local SkipsFrame = GridButtonsFrame.SkipsFrame

--Functions
function GridButtons._shop_button_clicked()
	InterfaceUtilities.toggle_screen("GameShop")
end

function GridButtons._inventory_button_clicked()
	InterfaceUtilities.toggle_screen("VehicleInventory")
end

function GridButtons._buy_skips_clicked()
	SkipServiceClient:prompt_skip_purchase()
end

function GridButtons._use_skips_clicked()
	SkipServiceClient:use_skip()
end

function GridButtons._update_skip_timer(time_in_seconds: number)
	local min, sec = tostring(math.floor(time_in_seconds / 60)), tostring(time_in_seconds % 60)
	if #sec == 1 then
		sec = "0" .. sec
	end
	SkipsFrame.FreeSkipsTimer.Text = "Free skip in: " .. tostring(min) .. ":" .. tostring(sec)
end

function GridButtons._update_skip_amount(amount: number)
	SkipsFrame.SkipsIndicator.SkipsLabel.Text = "Skip (" .. tostring(amount) .. ")"
end

function GridButtons.init()
	GridButtonsFrame.ShopButton.MouseButton1Click:Connect(GridButtons._shop_button_clicked)
	GridButtonsFrame.InventoryButton.MouseButton1Click:Connect(GridButtons._inventory_button_clicked)
	GridButtonsFrame.SkipsFrame.SkipsIndicator.MouseButton1Click:Connect(GridButtons._use_skips_clicked)
	GridButtonsFrame.SkipsFrame.BuySkips.MouseButton1Click:Connect(GridButtons._buy_skips_clicked)
	SkipServiceClient:listen_to_timer(GridButtons._update_skip_timer)
	DataServiceClient.connect_to_value_changed({ "skips" }, GridButtons._update_skip_amount)
end

return GridButtons

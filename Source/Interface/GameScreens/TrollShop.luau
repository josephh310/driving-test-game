--[[
    @Title: Troll Shop
    @Author: 010DevX101
    @Description: Manages the troll shop screen visibility for purchasing troll items.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)

local TrollShop = {}

-- Dependancies
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local TrollShopFrame = Interface.Screens.TrollShop
local List = TrollShopFrame.List

-- Functions
function TrollShop.hide()
	TrollShopFrame.Visible = false
end

function TrollShop.show()
	TrollShopFrame.Visible = true
end

function TrollShop.init()
	TrollShop.hide_ui_when_open = false
    for _, troll in List:GetChildren() do
        if not troll:IsA("ImageButton") then
            continue
        end
        troll.MouseButton1Click:Connect(function()
            MarketplaceServiceClient:purchase_product("troll_everyone")
        end)
    end
end

return TrollShop

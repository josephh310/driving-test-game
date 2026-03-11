--[[
    @Title: Gift Screen
    @Author: Joseph (BreakLoop)
    @Description: Displays a list of players in the server and allows the local player to gift a product to another player.
]]

local GiftScreen = {
	Connections = {},
}

-- Dependancies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Assets = ReplicatedStorage.Assets
local UIAssets = Assets.Interface
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local GiftScreenFrame = Interface.Screens.GiftScreen

-- Functions
function GiftScreen._clear_content()
	for _, connection in GiftScreen.Connections do
		connection:Disconnect()
	end
	for _, user_gift_row in GiftScreenFrame.content.ConversationList:GetChildren() do
		if not user_gift_row:IsA("ImageLabel") then
			continue
		end
		user_gift_row:Destroy()
	end
end

function GiftScreen.hide()
	GiftScreenFrame.Visible = false
	GiftScreen._clear_content()
end

function GiftScreen.show(product_code: string)
	GiftScreen._clear_content()
	GiftScreenFrame.Visible = true
	if not product_code then
		return
	end
	for _, player: Player in Players:GetPlayers() do
		if player == Players.LocalPlayer then
			continue
		end
		local new_row = UIAssets.GiftUserTemplate:Clone()
		new_row.Thumbnail.Image =
			Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		new_row.UserInfo.Username.Text = player.Name
		new_row.UserInfo.DisplayNameWrapper.DisplayName.Text = player.DisplayName
		GiftScreen.Connections[#GiftScreen.Connections + 1] = new_row.GiftButton.MouseButton1Click:Connect(function()
			MarketplaceServiceClient:gift_product(product_code, player)
			InterfaceUtilities.toggle_screen("GiftScreen")
		end)
		new_row.Parent = GiftScreenFrame.content.ConversationList
	end
end

function GiftScreen.init()
	GiftScreen.hide_ui_when_open = false
	GiftScreenFrame.content.Header.BackButton.MouseButton1Click:Connect(function()
		InterfaceUtilities.toggle_screen("GiftScreen")
	end)
end

return GiftScreen

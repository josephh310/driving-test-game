--[[
    @Title: Prompt Gift Command
    @Author: Joseph (BreakLoop)
    @Description: Admin command that prompts a gift purchase from one player to another for a specified product.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceServiceServer = require(ServerScriptService.Services.MarketplaceService.MarketplaceServiceServer)
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchShared = require(ReplicatedStorage.Shared.Services.Conch.ConchShared)

return {
	description = "Gift a product to a player",
	permissions = {
		ConchShared.permissions.edit_user_data,
	},
	arguments = function()
		local gifter = Conch.args.player("gifter", "The player which is gifting the product")
		local recipient = Conch.args.player("recipient", "The player who is recieving the product")
		local product_code = Conch.args.string("product_code", "The product code")
		return gifter, recipient, product_code
	end,
	callback = function(gifter, recipient, product_code)
		print(MarketplaceServiceServer:prompt_gift_purchase(gifter, recipient.UserId, product_code))
	end,
}

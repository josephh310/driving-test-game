--[[
    @Title: Give Badge Command
    @Author: Joseph (BreakLoop)
    @Description: Admin command that awards a specified badge to a target player.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeServiceServer = require(ServerScriptService.Services.BadgeService.BadgeServiceServer)
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchShared = require(ReplicatedStorage.Shared.Services.Conch.ConchShared)

return {
	description = "Gives a given player a badge",
	permissions = {
		ConchShared.permissions.award_badges,
	},
	arguments = function()
		local player = Conch.args.player("player", "Player to give a badge to")
		local badge_index = Conch.args.string("badge name", "Index of the badge to give the player")
		return player, badge_index
	end,
	callback = function(player, badge_name)
		local badge_id = BadgeServiceServer.badges[badge_name]
		if not badge_id then
			return
		end
		BadgeServiceServer:award_badge(player, badge_id)
	end,
}

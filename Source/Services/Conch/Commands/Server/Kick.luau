--[[
    @Title: Kick Command
    @Author: Joseph (BreakLoop)
    @Description: Admin command that kicks a specified player from the server with a given reason.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchShared = require(ReplicatedStorage.Shared.Services.Conch.ConchShared)

return {
	description = "Kicks the given player from the server",
	permissions = {
		ConchShared.permissions.kick_players,
	},
	arguments = function()
		local player = Conch.args.player("player", "The player that should be kicked from the server")
		local reason = Conch.args.string("reason", "The reason why the player has been kicked from the user")
		return player, reason
	end,
	callback = function(player, reason)
		player:Kick(reason)
	end,
}

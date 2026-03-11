--[[
    @Title: Badge Service (Server)
    @Author: Joseph (BreakLoop)
    @Description: Awards badges to players and tracks owned badges in the player's data store.
]]

local BadgeServiceServer = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local BadgeService = game:GetService("BadgeService")

BadgeServiceServer.badges = {
	welcome = 1333398432526365,
	stage_10 = 2586291309616850,
	stage_20 = 1799699978815083,
	stage_30 = 3736276348916623,
	stage_40 = 2807234818059701,
	stage_50 = 3247666506209402,
	winning = 1298548968862929,
}

-- Types
export type BadgeServiceServer = typeof(BadgeServiceServer)

function BadgeServiceServer.award_badge(self: BadgeServiceServer, player: Player, badge_id: number)
	-- Check badge ID is valid
	if typeof(badge_id) ~= "number" then
		warn(`Badge ID is invalid`)
		return
	end

	-- Fetch currently owned badges, check if badge has already been rewarded
	-- Reject if already rewarded
	local owned_badges = DataServiceServer:get_value(player, { "badges" })
	if table.find(owned_badges, badge_id) then
		warn(`{player.Name} already has badge {badge_id}`)
		return
	end

	-- Attempt to reward the player a badge
	local success, error_message = pcall(function()
		BadgeService:AwardBadgeAsync(player.UserId, badge_id)
	end)
	if not success then
		warn(error_message)
		return
	end

	-- Add the badge to the player's data
	DataServiceServer:apply_change(player, { "badges" }, function(current: { number })
		table.insert(current, badge_id)
		return current
	end)
end

function BadgeServiceServer.init(self: BadgeServiceServer)
	self.networker = Networker.server.new("BadgeService")
end

return BadgeServiceServer

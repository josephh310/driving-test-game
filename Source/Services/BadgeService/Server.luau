--[[
    @Title: Badge Service (Server)
    @Author: Joseph (BreakLoop)
    @Description: Awards badges to players and tracks owned badges in the player's data store.
]]

local BadgeServiceServer = {
	_connections = {},
}

-- Dependencies
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local BadgeService = game:GetService("BadgeService")

BadgeServiceServer.badges = {
	welcome = 1333398432526365,
	stage_10 = 2586291309616850,
	stage_20 = 1799699978815083,
	stage_30 = 3736276348916623,
	stage_40 = 2807234818059701,
	stage_50 = 3247666506209402,
	winner = 1298548968862929,
}

-- Stage thresholds mapped to badge IDs
BadgeServiceServer.stage_badges = {
	{ stage = 10, badge = BadgeServiceServer.badges.stage_10 },
	{ stage = 20, badge = BadgeServiceServer.badges.stage_20 },
	{ stage = 30, badge = BadgeServiceServer.badges.stage_30 },
	{ stage = 40, badge = BadgeServiceServer.badges.stage_40 },
	{ stage = 50, badge = BadgeServiceServer.badges.stage_50 },
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

function BadgeServiceServer._check_stage_badges(self: BadgeServiceServer, player: Player, best_stage: number)
	for _, entry in self.stage_badges do
		if best_stage >= entry.stage then
			self:award_badge(player, entry.badge)
		end
	end
end

function BadgeServiceServer._player_added(self: BadgeServiceServer, player: Player)
	-- Wait for the player's data to load
	local profile = DataServiceServer:get_profile(player)
	if not profile then
		return
	end

	-- Award welcome badge
	self:award_badge(player, self.badges.welcome)

	-- Listen to best_stage leaderstat changes
	local leaderstats = player:WaitForChild("leaderstats")
	local best_stage_value = leaderstats:WaitForChild("Best Stage")
	self._connections[player] = best_stage_value.Changed:Connect(function(new_value: number)
		self:_check_stage_badges(player, new_value)
	end)
end

function BadgeServiceServer._player_removed(self: BadgeServiceServer, player: Player)
	local connection = self._connections[player]
	if connection then
		connection:Disconnect()
		self._connections[player] = nil
	end
end

function BadgeServiceServer.init(self: BadgeServiceServer)
	-- Listen for players joining and leaving
	for _, player in Players:GetPlayers() do
		task.defer(function()
			self:_player_added(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		self:_player_added(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:_player_removed(player)
	end)
end

return BadgeServiceServer

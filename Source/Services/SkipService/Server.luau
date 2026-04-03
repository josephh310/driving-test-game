--[[
    @Title: Skip Service (Server)
    @Author: Joseph (BreakLoop)
    @Description: Manages stage skipping, awarding timed skip tokens to players and handling skip consumption and stage navigation.
]]

local SkipServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local SkipServiceShared = require(ReplicatedStorage.Shared.Services.SkipService.SkipServiceShared)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

-- Types
export type SkipServiceServer = typeof(SkipServiceServer)

-- Constants
local cleanup_functions = {}

-- Functions
function SkipServiceServer.get_player_timer(self: SkipServiceServer, player: Player)
	return player:GetAttribute(SkipServiceShared.timer_attribute_name)
end

function SkipServiceServer.set_player_timer(self: SkipServiceServer, player: Player, time: number)
	player:SetAttribute(SkipServiceShared.timer_attribute_name, time)
end

function SkipServiceServer._player_removing(self: SkipServiceServer, player: Player)
	cleanup_functions[player]()
end

function SkipServiceServer._player_added(self: SkipServiceServer, player: Player)
	-- Init attribute
	self:set_player_timer(player, SkipServiceShared.skip_timer_seconds)

	-- Loop until player leaves
	local session_active = true
	repeat
		local timer_value = self:get_player_timer(player)
		task.wait(1)
		if timer_value <= 0 then
			self:set_player_timer(player, SkipServiceShared.skip_timer_seconds)
			self:give_skip(player)
		else
			self:set_player_timer(player, timer_value - 1)
		end
	until session_active == false

	-- Store cleanup function for when the player leaves
	cleanup_functions[player] = function()
		session_active = false
	end
end

function SkipServiceServer.give_skip(self: SkipServiceServer, player: Player)
	DataServiceServer:apply_change(player, { "skips" }, function(current_value: number)
		return current_value + 1
	end)
end

function SkipServiceServer.use_skip(self: SkipServiceServer, player: Player)
	-- Take a skip from the player
	DataServiceServer:apply_change(player, { "skips" }, function(current_skips: number)
		-- Check if the player has skips
		-- If not, reject and keep the number of skips the same
		if current_skips <= 0 then
			return current_skips
		end

        local success = false

		-- The player has skips, consume one and increment their best stage
		DataServiceServer:apply_change(player, { "best_stage" }, function(current_best: number)
			-- Increment best stage
			local new_stage = current_best + 1

            local max_stage = VehicleServiceUtils.get_max_stage()
            if new_stage > max_stage then
                return current_best
            end

            success = true

			-- Set the player's current stage to the new best stage
			DataServiceServer:set_value(player, { "current_stage" }, new_stage)

			-- Return the new best stage
			return new_stage
		end)

        if not success then
            return current_skips
        end

        -- Reset the vehicle
        VehicleServiceServer:reset_vehicle(player)
		
		-- Decrement the number of skips the player has
		return current_skips - 1
	end)
end

function SkipServiceServer.go_forewards(self: SkipServiceServer, player: Player)
	local changed = false
	DataServiceServer:apply_change(player, { "current_stage" }, function(current_value: number)
		local next_stage = current_value + 1
		local best_stage = DataServiceServer:get_value(player, { "best_stage" })
		if next_stage > best_stage then
			return current_value
		end
		changed = true
		return next_stage
	end)
	if changed then
        VehicleServiceServer:reset_vehicle(player)
	end
end

function SkipServiceServer.go_backwards(self: SkipServiceServer, player: Player)
	local changed = false
	DataServiceServer:apply_change(player, { "current_stage" }, function(current_value: number)
		if current_value <= 1 then
			return current_value
		end
		changed = true
		return current_value - 1
	end)
	if changed then
		VehicleServiceServer:reset_vehicle(player)
	end
end

function SkipServiceServer.init(self: SkipServiceServer)
	-- Expose use_skip to the client
	self.networker = Networker.server.new("SkipService", self, {
		self.use_skip,
		self.go_forewards,
		self.go_backwards,
	})

	-- Registed players already in the game
	for index, player in Players:GetPlayers() do
		task.defer(function()
			self:_player_added(player)
		end)
	end

	-- Listen for future players added
	Players.PlayerAdded:Connect(function(player)
		SkipServiceServer:_player_added(player)
	end)
end

return SkipServiceServer

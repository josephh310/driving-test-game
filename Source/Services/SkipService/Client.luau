--[[
    @Title: Skip Service (Client)
    @Author: Joseph (BreakLoop)
    @Description: Client-side skip service that tracks the skip timer, listens for updates, and handles skip usage or purchase prompts.
]]

local SkipServiceClient = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InterfaceUtilities = require(ReplicatedStorage.Interface.Utilities)
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local SkipServiceShared = require(script.Parent.SkipServiceShared)

-- Constants
local timer_connections = {}
local player = Players.LocalPlayer

-- Types
export type SkipServiceClient = typeof(SkipServiceClient)
export type Timer = number

-- Functions
function SkipServiceClient._timer_updated(self: SkipServiceClient)
	local value = self:get_timer()
	for index, callback in timer_connections do
		callback(value)
	end
end

function SkipServiceClient.get_timer(self: SkipServiceClient)
	-- :3
	return player:GetAttribute(SkipServiceShared.timer_attribute_name)
end

function SkipServiceClient.listen_to_timer(self: SkipServiceClient, callback: (Timer) -> ())
	-- Store the callback to call whenever the SkipTimer updates
	local callback_index = #timer_connections + 1
	timer_connections[callback_index] = callback

	-- Send an initial value to the callback to instantly update ui
	local current_time = self:get_timer()
	callback(current_time)

	-- Return a function to disconnect the listener
	return function()
		timer_connections[callback_index] = nil
	end
end

function SkipServiceClient.prompt_skip_purchase(self: SkipServiceClient)
	InterfaceUtilities.toggle_screen("GameShop", 1)
end

function SkipServiceClient.use_skip(self: SkipServiceClient)
	if DataServiceClient:get_data().skips > 0 then
		SkipServiceClient.networker:fire("use_skip")
	else
		self:prompt_skip_purchase()
	end
end

function SkipServiceClient.init(self: SkipServiceClient)
	-- Init client networker
	self.networker = Networker.client.new("SkipService", self)

	-- Subscribe to SkipTimer replication from the server
	player:GetAttributeChangedSignal(SkipServiceShared.timer_attribute_name):Connect(function()
		self:_timer_updated()
	end)
end

return SkipServiceClient

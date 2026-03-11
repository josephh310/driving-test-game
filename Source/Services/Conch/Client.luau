--[[
    @Title: Conch Admin (Client)
    @Author: Joseph (BreakLoop)
    @Description: Client-side admin system that mounts the admin panel UI, creates the topbar toggle, and loads client commands.
]]

local ConchClient = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchUi = require(ReplicatedStorage.Packages.ConchUi)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local ConchShared = require(ReplicatedStorage.Shared.Services.Conch.ConchShared)

-- Types
export type ConchClient = typeof(ConchClient)

-- Constants
local commands_folder = ReplicatedStorage.Shared.Services.Conch.Commands
local commands_client = commands_folder.Client

-- Functions
function ConchClient._toggle_panel(self: ConchClient)
	-- Get the current state (open/closed)
	local current_state = ConchUi.opened()

	-- Set the current state to the opposite to toggle the interface
	ConchUi.opened(not current_state)
end

function ConchClient._create_toggle(self: ConchClient)
	-- Check if the toggle has already been created
	if self.panel_toggle then
		return
	end

	-- Get local player's roles
	local player = Players.LocalPlayer
	local permissions = ConchShared:get_player_roles(player)

	-- If they don't have any roles, abort (they don't need to toggle the admin panel)
	if not permissions then
		return
	end

	-- The player has permissions, add the admin panel toggle
	self.panel_toggle = TopbarPlus.new()
	self.panel_toggle:setImage(102459578526748)
	self.panel_toggle:setLabel("Admin")
	self.panel_toggle:oneClick(true)
	self.panel_toggle:bindEvent("selected", self._toggle_panel)
end

function ConchClient.init(self: ConchClient)
	-- Init conch
	Conch.initiate_default_lifecycle()

	-- Init UI
	ConchUi.mount()
	self:_create_toggle()

	-- Init commands
	ConchShared:load_command_directory(commands_client)
end

return ConchClient

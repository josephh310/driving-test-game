--[[
    @Title: Conch Admin (Server)
    @Author: Joseph (BreakLoop)
    @Description: Server-side admin system that registers roles, assigns permissions to players, and loads server commands.
]]

local ConchServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchShared = require(ReplicatedStorage.Shared.Services.Conch.ConchShared)

-- Types
export type ConchServer = typeof(ConchServer)

-- Constants
local commands_folder = ServerScriptService.Services.Conch.Commands
local commands_server = commands_folder.Server

-- Functions
function ConchServer._register_role(self: ConchServer, role_name: string, role_permissions: { string })
	-- Add the list of permissions to the role via conch
	Conch.set_role_permissions(role_name, table.unpack(role_permissions))
end

function ConchServer._give_role(self: ConchServer, player: Player, role_name: string)
	-- Get the conch player object
	local conch_user = Conch.get_user(player)

	-- Check the user exists
	if not conch_user then
		warn(`{player.Name} is not yet registered with conch`)
		return
	end

	-- Assign role
	print(`Given {player.Name} {role_name}`)
	Conch.give_roles(conch_user, role_name)
end

function ConchServer._player_added(self: ConchServer, player: Player)
	-- Get manually assigned roles
	local player_key = tostring(player.UserId)
	local player_roles = ConchShared.users[player_key]

	-- No need to continue of no manual roles exist
	if not player_roles then
		return
	end

	-- Assign all roles to the player
	for _, role_name in player_roles do
		ConchServer:_give_role(player, role_name)
	end
end

function ConchServer.init(self: ConchServer)
	-- Init conch
	Conch.initiate_default_lifecycle()

	-- Init roles
	for role_name, permissions in ConchShared.roles do
		self:_register_role(role_name, permissions)
	end

	-- Add roles to all current players
	for _, player in Players:GetPlayers() do
		task.defer(function()
			self:_player_added(player)
		end)
	end

	-- Listen for future players joining
	Players.PlayerAdded:Connect(function(player: Player)
		self:_player_added(player)
	end)

	-- Init commands
	ConchShared:load_command_directory(commands_server)
end

return ConchServer

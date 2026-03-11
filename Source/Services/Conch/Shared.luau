--[[
    @Title: Conch Admin (Shared)
    @Author: Joseph (BreakLoop)
    @Description: Shared configuration for the admin system, defining permissions, roles, user assignments, and command registration utilities.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local ConchShared = {}

-- Types
export type ConchShared = typeof(ConchShared)
export type CommandArgs = { any }
export type CommandData = {
	permissions: { string },
	arguments: (nil) -> CommandArgs,
	callback: (CommandArgs) -> nil,
}

-- Values
ConchShared.permissions = {
	["kick_players"] = 1,
	["edit_user_data"] = 2,
	["spawn_vehicles"] = 3,
	["award_badges"] = 4,
}

ConchShared.roles = {
	["admin"] = {
		ConchShared.permissions.kick_players,
		ConchShared.permissions.spawn_vehicles,
	},
	["owner"] = {
		ConchShared.permissions.kick_players,
		ConchShared.permissions.edit_user_data,
		ConchShared.permissions.spawn_vehicles,
		ConchShared.permissions.award_badges,
	},
}

ConchShared.users = {
	["2901872175"] = { "owner" }, -- BreakLoop
	["2288136410"] = { "owner" }, -- 010DevX101
	["23899869"] = { "owner" }, -- MustacheJoey
}

-- Functions
function ConchShared.get_player_roles(self: ConchShared, player: Player)
	if not player then
		return
	end
	return self.users[tostring(player.UserId)]
end

--[[
    This function takes EITHER command arguments or a quick function
    It then registers the command with Conch on either the client or the server
]]
function ConchShared.register_command(
	self: ConchShared,
	command_name: string,
	command_data: CommandData | (CommandArgs) -> ()
)
	if typeof(command_data) == "function" then
		-- No detailed data has been provided
		-- Create a quick command
		Conch.register_quick(command_name, command_data)
	elseif typeof(command_data) == "table" then
		-- Detailed command specifications have been provided
		-- Create an advanced ommand
		Conch.register(command_name, command_data)
	end
end

function ConchShared.load_command_directory(self: ConchShared, directory: Folder)
	for _, module: ModuleScript in directory:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end
		self:register_command(module.Name, require(module))
	end
end

return ConchShared

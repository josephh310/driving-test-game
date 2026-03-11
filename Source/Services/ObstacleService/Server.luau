--[[
    @Title: Obstacle Service (Server)
    @Author: Joseph (BreakLoop)
    @Description: Initialises server-side obstacle components by observing tagged instances in the workspace.
]]

local ObstacleServiceServer = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Observers = require(ReplicatedStorage.Packages.Observers)

-- Constants
local Components = ServerScriptService.Modules.Components.Server

-- Types
export type ObstacleServiceServer = typeof(ObstacleServiceServer)

-- Functions
function ObstacleServiceServer.init(self: ObstacleServiceServer)
	for index, module: ModuleScript in Components:GetChildren() do
		local observer_fn = require(module)
		Observers.observeTag(module.Name, observer_fn, { workspace })
	end
end

return ObstacleServiceServer

--[[
    @Title: Obstacle Service (Client)
    @Author: Joseph (BreakLoop)
    @Description: Initialises client-side obstacle components by observing tagged instances in the workspace.
]]

local ObstacleServiceClient = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

-- Constants
local Components = ReplicatedStorage.Shared.Modules.Components.Client

-- Types
export type ObstacleServiceClient = typeof(ObstacleServiceClient)

-- Functions
function ObstacleServiceClient.init(self: ObstacleServiceClient)
	for index, module: ModuleScript in Components:GetChildren() do
		local observer_fn = require(module)
		Observers.observeTag(module.Name, observer_fn, { workspace })
	end
end

return ObstacleServiceClient

--[[
    @Title: Server Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes server-side services.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ConchServer = require(ServerScriptService.Services.Conch.ConchServer)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local BadgeServiceServer = require(ServerScriptService.Services.BadgeService.BadgeServiceServer)
local CameraServiceServer = require(ServerScriptService.Services.CameraService.CameraServiceServer)
local MarketplaceServiceServer = require(ServerScriptService.Services.MarketplaceService.MarketplaceServiceServer)
local ObstacleServiceServer = require(ServerScriptService.Services.ObstacleService.ObstacleServiceServer)
local PhysicsServiceServer = require(ServerScriptService.Services.PhysicsService.PhysicsServiceServer)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)
local SkipServiceServer = require(ServerScriptService.Services.SkipService.SkipServiceServer)
local ProximityServiceServer = require(ServerScriptService.Services.ProximityService.ProximityServiceServer)

DataServiceServer:init()
BadgeServiceServer:init()
MarketplaceServiceServer:init()
PhysicsServiceServer:init()
SkipServiceServer:init()
VehicleServiceServer:init()
ObstacleServiceServer:init()
CameraServiceServer:init()
ProximityServiceServer:init()
ConchServer:init()
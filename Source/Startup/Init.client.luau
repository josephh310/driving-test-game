--[[
    @Title: Client Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes client-side services.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local Interface = require(ReplicatedStorage.Interface)
local CameraServiceClient = require(ReplicatedStorage.Shared.Services.CameraService.CameraServiceClient)
local ConchClient = require(ReplicatedStorage.Shared.Services.Conch.ConchClient)
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local MusicServiceClient = require(ReplicatedStorage.Shared.Services.MusicService.MusicServiceClient)
local ObstacleServiceClient = require(ReplicatedStorage.Shared.Services.ObstacleService.ObstacleServiceClient)
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local SkipServiceClient = require(ReplicatedStorage.Shared.Services.SkipService.SkipServiceClient)
local ProximityServiceClient = require(ReplicatedStorage.Shared.Services.ProximityService.ProximityServiceClient)
local InputServiceClient = require(ReplicatedStorage.Shared.Services.InputService.InputServiceClient)

DataServiceClient:init()
MarketplaceServiceClient:init()
VehicleServiceClient:init()
ObstacleServiceClient:init()
InputServiceClient:init()
SkipServiceClient:init()
MusicServiceClient:init()
Interface:init()
CameraServiceClient:init()
ProximityServiceClient:init()
ConchClient:init()

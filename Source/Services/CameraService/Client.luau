--[[
    @Title: Camera Service (Client)
    @Author: Joseph (BreakLoop)
    @Description: Handles client-side camera shake effects using presets from RbxCameraShaker.
]]

local CameraServiceClient = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local RbxCameraShaker = require(ReplicatedStorage.Packages.RbxCameraShaker)

-- Types
export type CameraService = typeof(CameraServiceClient)

-- Functions
function CameraServiceClient._shake_camera(shake_cframe: CFrame)
	-- meow
	workspace.CurrentCamera.CFrame *= shake_cframe
end

function CameraServiceClient.apply_shake(self: CameraService, shake_preset: string)
	local preset = RbxCameraShaker.Presets[shake_preset]
	if not preset then
		warn(`{shake_preset} is not a valid preset.`)
		return
	end
	self.camera_shaker:Shake(preset)
end

function CameraServiceClient.init(self: CameraService)
	self.networker = Networker.client.new("CameraService", self)
	self.camera_shaker = RbxCameraShaker.new(Enum.RenderPriority.Camera.Value + 1, self._shake_camera)
	self.camera_shaker:Start()
end

return CameraServiceClient

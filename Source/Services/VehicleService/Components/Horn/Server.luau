--[[
    @Title: Horn Component (Server)
    @Author: 010DevX101
    @Description: Handles server-side horn logic, cloning the horn sound onto the vehicle and playing it with a cooldown on honk requests.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local Vehicles = workspace.Vehicles

local Horn = {}

local cooldown: { [Player]: true } = {}

local function cleanup(player: Player)
	cooldown[player] = nil
end

function Horn.init(player: Player, model: Model, sound: Sound)
	local clone = sound:Clone()
	clone.Name = "HornSound"
	clone.Parent = model.PrimaryPart
	return function()
		cleanup(player)
	end
end

function Horn.honk(self: typeof(Horn), player: Player)
	if cooldown[player] then
		return
	end
	local vehicle = Vehicles:FindFirstChild(player.Name)
	if not vehicle or not vehicle:IsA("Model") then
		return
	end
	local sound = vehicle.PrimaryPart:FindFirstChild("HornSound")
	if not sound or not sound:IsA("Sound") then
		return
	end
	cooldown[player] = true
	sound:Play()
	task.delay(1 + sound.TimeLength, function()
		cleanup(player)
	end)
end

Networker.server.new("Horn", Horn, { Horn.honk })
game:GetService("Players").PlayerRemoving:Connect(cleanup)

return Horn

--[[
    @Title: Horn Component (Client)
    @Author: 010DevX101
    @Description: Binds the horn input action to the H key and touch button, firing a network event to honk the vehicle horn.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Networker = require(ReplicatedStorage.Packages.Networker)

local Horn = {}

local networker = Networker.client.new("Horn", Horn)

function Horn.init()
	local bind_name = "Honk"
	local use_touch_button = true
	local key_codes = { Enum.KeyCode.H }
	ContextActionService:BindAction(bind_name, function()
		networker:fire("honk")
	end, use_touch_button, table.unpack(key_codes))
	local button = ContextActionService:GetButton(bind_name)
	if button then
		button.ActionIcon.Image = "rbxassetid://12339036604"
		button.ActionIcon.Size = UDim2.fromScale(0.5, 0.5)
		button.ActionIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		button.ActionIcon.Position = UDim2.fromScale(0.5, 0.5)
		button.ActionIcon.ImageColor3 = Color3.fromRGB(0, 0, 0)
	end
	return function()
		ContextActionService:UnbindAction(bind_name)
	end
end

return Horn

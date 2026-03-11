--[[
    @Title: Topbar
    @Author: Joseph (BreakLoop)
    @Description: Controls the HUD topbar displaying the current stage and providing navigation buttons for stage progression.
]]

local Topbar = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local SkipServiceClient = require(ReplicatedStorage.Shared.Services.SkipService.SkipServiceClient)
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local TopbarFrame = Interface.HUD.Topbar
local HideTween = TweenService:Create(
	TopbarFrame,
	TweenInfo.new(0.25),
	{ Position = UDim2.fromScale(TopbarFrame.Position.X.Scale, -0.5) }
)
local ShowTween = TweenService:Create(
	TopbarFrame,
	TweenInfo.new(0.25),
	{ Position = UDim2.fromScale(TopbarFrame.Position.X.Scale, 0.01) }
)

-- Functions
function Topbar._update_current_stage(new_value: number)
	local stage_formatted = string.format("%02d", new_value)
	TopbarFrame.StageIndicator.StageLabel.Text = "STAGE " .. stage_formatted
end

function Topbar._next_stage_clicked()
	SkipServiceClient.networker:fire("go_forewards")
end

function Topbar._previous_stage_clicked()
	SkipServiceClient.networker:fire("go_backwards")
end

function Topbar._skip_all_clicked()
	MarketplaceServiceClient:purchase_product("skip_to_end")
end

function Topbar.hide()
	HideTween:Play()
end

function Topbar.show()
	ShowTween:Play()
end

function Topbar.init()
	TopbarFrame.Next.MouseButton1Click:Connect(Topbar._next_stage_clicked)
	TopbarFrame.Previous.MouseButton1Click:Connect(Topbar._previous_stage_clicked)
	TopbarFrame.SkipAll.MouseButton1Click:Connect(Topbar._skip_all_clicked)
	DataServiceClient.connect_to_value_changed({ "current_stage" }, Topbar._update_current_stage)
end

return Topbar

--[[
    @Title: Custom Topbar
    @Author: Joseph (BreakLoop)
    @Description: Adds a custom topbar icon using TopbarPlus that prompts players to invite friends.
]]

local CustomTopbar = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

--Functions
function CustomTopbar._prompt_invite_friends()
	SocialService:PromptGameInvite(Players.LocalPlayer)
end

function CustomTopbar.init()
	CustomTopbar.FriendsIcon = TopbarPlus.new()
	CustomTopbar.FriendsIcon:setImage(10885655986)
	CustomTopbar.FriendsIcon:setLabel("Invite")
	CustomTopbar.FriendsIcon:oneClick(true)
	CustomTopbar.FriendsIcon:bindEvent("selected", CustomTopbar._prompt_invite_friends)
end

return CustomTopbar

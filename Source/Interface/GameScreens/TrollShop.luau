--[[
    @Title: Troll Shop
    @Author: Joseph (BreakLoop)
    @Description: Manages the troll shop screen visibility for purchasing troll items.
]]

local TrollShop = {}

-- Dependancies
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local TrollShopFrame = Interface.Screens.TrollShop

-- Functions
function TrollShop.hide()
	TrollShopFrame.Visible = false
end

function TrollShop.show()
	TrollShopFrame.Visible = true
end

function TrollShop.init()
	TrollShop.hide_ui_when_open = false
end

return TrollShop

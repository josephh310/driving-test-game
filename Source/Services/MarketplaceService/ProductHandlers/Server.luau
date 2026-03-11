--[[
    @Title: Product Handlers (Server)
    @Author: Joseph (BreakLoop)
    @Description: Server-side product receipt handlers that grant skip tokens to players upon purchase.
]]

-- Dependencies
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)

-- Functions
local function AddSkips(num_skips: number)
	return function(player: Player)
		DataServiceServer:apply_change(player, { "skips" }, function(current_skips: number)
			return current_skips + num_skips
		end)
	end
end

-- Meow
return {
	skip_1 = {
		on_recieved = AddSkips(1),
	},
	skip_5 = {
		on_recieved = AddSkips(5),
	},
	skip_10 = {
		on_recieved = AddSkips(10),
	},
	skip_30 = {
		on_recieved = AddSkips(30),
	},
}

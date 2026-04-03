--[[
    @Title: Product Handlers (Server)
    @Author: Joseph (BreakLoop)
    @Description: Server-side product receipt handlers that grant skip tokens to players upon purchase.
]]

-- Dependencies
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)

-- Functions
local function add_skips(num_skips: number)
	return function(player: Player)
		DataServiceServer:apply_change(player, { "skips" }, function(current_skips: number)
			return current_skips + num_skips
		end)
	end
end

local function skip_to_end()
    return function(player: Player)
		DataServiceServer:apply_change(player, { "best_stage" }, function(current_best: number)
            local max_stage = VehicleServiceServer.max_stage
			DataServiceServer:set_value(player, { "current_stage" }, max_stage)
			return max_stage
		end)

        VehicleServiceServer:reset_vehicle(player)
    end
end

-- Meow
return {
	skip_1 = {
		on_recieved = add_skips(1),
	},
	skip_5 = {
		on_recieved = add_skips(5),
	},
	skip_10 = {
		on_recieved = add_skips(10),
	},
	skip_30 = {
		on_recieved = add_skips(30),
	},
    skip_to_end = {
        on_recieved = skip_to_end()
    }
}

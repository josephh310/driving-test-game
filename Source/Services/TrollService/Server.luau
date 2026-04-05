--[[
    @Title: Troll Service (Server)
    @Author: 010DevX101
    @Description: Manages trolls that affect every player or individual players.
]]

local TrollServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")

-- Types
export type TrollServiceServer = typeof(TrollServiceServer)

function TrollServiceServer._kill_player(self: TrollServiceServer, player: Player)
    local character = player.Character
    if not character then
        return
    end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        return
    end
    humanoid:TakeDamage(math.huge)
end

function TrollServiceServer.explode_car_troll(self: TrollServiceServer, troll: Player, target: Player?)
    if target then
        self:_kill_player(target)
        return
    end
    for _, player in Players:GetPlayers() do
        if player == troll then
            continue
        end
        self:_kill_player(player)
    end
end

return TrollServiceServer
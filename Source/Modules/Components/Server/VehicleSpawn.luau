--[[
    @Title: Vehicle Spawn
    @Author: Joseph (BreakLoop)
    @Description: Hides a vehicle spawn point by setting its transparency to 1 at runtime.
]]

return function(spawn: BasePart)
	if not spawn:IsA("BasePart") then
		return
	end
	spawn.Transparency = 1
end

--[[
    @Title: Play Sound From Part
    @Author: Joseph (BreakLoop)
    @Description: Clones a sound instance and plays it from a given part, automatically cleaning it up after playback.
]]

local Debris = game:GetService("Debris")

return function(part: BasePart, sound: Sound)
	local new_sound = sound:Clone()
	new_sound.Parent = part
	new_sound:Play()
	Debris:AddItem(new_sound, new_sound.TimeLength)
end

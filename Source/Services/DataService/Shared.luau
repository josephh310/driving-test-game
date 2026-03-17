--[[
    @Title: DataService Settings
    @Author: Joseph (BreakLoop)
    @Description: 
        Configuration for DataService.
        Game-specific save template configuration.
        Game-specific leaderstat configuration.
        Game-specific config flags.
]]

local DataServiceShared = {}

export type PlayerData = {
	current_stage: number,
	best_stage: number,
	skips: number,
	badges: { number },
	vehicles: Vehicles,
	equipped_vehicle: string,
	products_owned: { string },
	purchase_history: { any },
	plate: string?,
}

export type Vehicles = {
	[string]: {
		color: { r: number, g: number, b: number }?,
	},
}

DataServiceShared.template = {
	current_stage = 1,
	best_stage = 1,
	skips = 0,
	badges = {},
	vehicles = { ["hatchback"] = {}, ["suv"] = {}, ["sports_racer"] = {}, ["convertable"] = {} }, -- for debugging
	equipped_vehicle = "hatchback",
	products_owned = {},
} :: PlayerData

DataServiceShared.leaderstats = {
	current_stage = "Stage",
	best_stage = "Best Stage",
}

DataServiceShared.flags = {
	PROFILE_STORE_NAME = "PlayerStore",
	MOCK_STORE_IN_STUDIO = false,
}

return DataServiceShared

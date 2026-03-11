--[[
    @Title: Vehicle Types
    @Author: 010DevX101
    @Description: Defines vehicle data types and the registry of all available vehicles with their models, health, and component configurations.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local Vehicles = Assets.Vehicles
local SoundEffects = Assets.SoundEffects

export type VehicleData = {
	["data"]: {
		display_name: string,
		vehicle_model: Model,
		health: number,
	},
	["components"]: {
		horn: {
			sound: Sound,
		}?,
		engine: {
			max_steer_angle: number,
		}?,
	},
}

return {
	["convertable"] = {
		data = {
			display_name = "Convertable",
			vehicle_model = Vehicles.ConvertableModel,
			health = 90,
		},
		components = {
			horn = { sound = SoundEffects.DefaultCarHorn },
			engine = { max_steer_angle = 25 },
		},
	},
	["sports_racer"] = {
		data = {
			display_name = "Sports Racer",
			vehicle_model = Vehicles.SportsRacerModel,
			health = 90,
		},
		components = {
			horn = { sound = SoundEffects.DefaultCarHorn },
			engine = { max_steer_angle = 25 },
		},
	},
	["hatchback"] = {
		data = {
			display_name = "Hatchback",
			vehicle_model = Vehicles.HatchbackModel,
			health = 90,
		},
		components = {
			horn = { sound = SoundEffects.DefaultCarHorn },
			engine = { max_steer_angle = 25 },
		},
	},
	["suv"] = {
		data = {
			display_name = "SUV",
			vehicle_model = Vehicles.SUVModel,
			health = 90,
		},
		components = {
			horn = { sound = SoundEffects.DefaultCarHorn },
			engine = { max_steer_angle = 25 },
		},
	},
}

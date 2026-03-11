--[[
    @Title: Engine Component (Client)
    @Author: 010DevX101
    @Description: Client-side vehicle engine that updates steering and throttle each frame using cylindrical constraints and wheel attachments.
]]

local RunService = game:GetService("RunService")

local Engine = {}

local actual_steer = 0
local actual_throttle = 0
local engine_update_loop: RBXScriptConnection? = nil

-- Functions
local function cleanup(
	vehicle_seat: VehicleSeat,
	cylindrical_constraints: { CylindricalConstraint },
	primary_wheel_attachments: { Attachment }
)
	if engine_update_loop then
		engine_update_loop:Disconnect()
	end
	for _, attachment in primary_wheel_attachments do
		attachment.Orientation = Vector3.new(-90, -90, 0)
	end
	for _, cylindrical in cylindrical_constraints do
		cylindrical.MotorMaxTorque = 0
		cylindrical.AngularVelocity = 0
	end
	vehicle_seat.AssemblyLinearVelocity = Vector3.zero
end

function Engine._update(
	dt: number,
	vehicle_seat: VehicleSeat,
	max_steer_angle: number,
	primary_wheel_attachments: { Attachment },
	cylindrical_constraints: { CylindricalConstraint }
)
	local steer_goal = -vehicle_seat.SteerFloat * max_steer_angle
	local throttle_goal = vehicle_seat.ThrottleFloat

	actual_steer += (steer_goal - actual_steer) * math.min(dt * vehicle_seat.TurnSpeed, 1)
	actual_throttle += (throttle_goal - actual_throttle) * math.min(dt * vehicle_seat.TurnSpeed, 1)

	local speed = vehicle_seat.MaxSpeed * actual_throttle
	local torque = vehicle_seat.Torque

	for _, attachment in primary_wheel_attachments do
		attachment.Orientation = Vector3.new(0, actual_steer, -90)
	end
	for _, cylindrical in cylindrical_constraints do
		cylindrical.MotorMaxTorque = torque
		cylindrical.AngularVelocity = (cylindrical.InclinationAngle > 0 and -speed or speed)
	end
end

function Engine.init(
	vehicle_seat: VehicleSeat,
	cylindrical_constraints: { CylindricalConstraint },
	primary_wheel_attachments: { Attachment },
	max_steer_angle: number
)
	if engine_update_loop then
		cleanup(vehicle_seat, cylindrical_constraints, primary_wheel_attachments)
	end
	engine_update_loop = RunService.Heartbeat:Connect(function(dt: number)
		Engine._update(dt, vehicle_seat, max_steer_angle, primary_wheel_attachments, cylindrical_constraints)
	end)
	return function()
		cleanup(vehicle_seat, cylindrical_constraints, primary_wheel_attachments)
	end
end

return Engine

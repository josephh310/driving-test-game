--[[
    @Title: HSV Color Wheel
    @Author: Joseph (BreakLoop)
    @Description: Generates an HSV color wheel as an EditableImage and provides a method to sample colors at a given position.
]]

local HSVColorWheel = {}

-- Dependencies
local AssetService = game:GetService("AssetService")

-- Constants
local BYTES_PER_PIXEL = 4

-- Helper functions
local function hsv_to_rgb(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6

	if i == 0 then
		return v, t, p
	end
	if i == 1 then
		return q, v, p
	end
	if i == 2 then
		return p, v, t
	end
	if i == 3 then
		return p, q, v
	end
	if i == 4 then
		return t, p, v
	end
	return v, p, q
end

-- Functions
function HSVColorWheel.create_wheel_editableimage(size: number)
	-- Check for invalid resolution, editable image sizes cannot be higher than 1024
	if size < 0 or size > 1024 then
		error("Invalid resolution")
	end

	-- Create an editable image to write custom pixels to
	local editable_image = AssetService:CreateEditableImage({
		Size = Vector2.new(size, size),
	})

	-- Create a pixel buffer, with an appropriate size to fit all pixels
	local pixel_buffer = buffer.create(size * size * BYTES_PER_PIXEL)
	local image_center = size / 2
	local image_radius = image_center
	local index = 0

	-- Write HSV wheel pixels to the buffer to be rendered
	for y = 0, size - 1 do
		for x = 0, size - 1 do
			local dx = x - image_center + 0.5
			local dy = y - image_center + 0.5
			local dist = math.sqrt(dx * dx + dy * dy)

			local r, g, b, a = 0, 0, 0, 0

			if dist <= image_radius then
				local angle = math.atan2(dy, dx)
				local hue = (angle / (2 * math.pi)) % 1
				local sat = dist / image_radius

				r, g, b = hsv_to_rgb(hue, sat, 1)
				a = 1
			end

			buffer.writeu8(pixel_buffer, index, math.floor(r * 255))
			buffer.writeu8(pixel_buffer, index + 1, math.floor(g * 255))
			buffer.writeu8(pixel_buffer, index + 2, math.floor(b * 255))
			buffer.writeu8(pixel_buffer, index + 3, math.floor(a * 255))

			index += 4
		end
	end

	-- Write the generated pixels to the editable image
	editable_image:WritePixelsBuffer(Vector2.new(0, 0), Vector2.new(size, size), pixel_buffer)

	return editable_image
end

function HSVColorWheel.get_color_at_position(editable_image: EditableImage, position: UDim2)
	-- Get the absolute pixel position from the relative UDim2 scale value
	local x_pixel_position = math.floor((editable_image.Size.X * position.X.Scale) + 0.5)
	local y_pixel_position = math.floor((editable_image.Size.Y * position.Y.Scale) + 0.5)

	-- Retrieve the pixel buffer from the editable image
	local pixel_position = Vector2.new(x_pixel_position, y_pixel_position)
	local pixel_buffer = editable_image:ReadPixelsBuffer(pixel_position, Vector2.new(1, 1))

	-- Extract and return the color data formatted as Color3
	return Color3.fromRGB(
		buffer.readu8(pixel_buffer, 0),
		buffer.readu8(pixel_buffer, 1),
		buffer.readu8(pixel_buffer, 2)
	)
end

return HSVColorWheel

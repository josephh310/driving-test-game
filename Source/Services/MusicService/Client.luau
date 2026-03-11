--[[
    @Title: Music Controller (Client)
    @Author: Joseph (BreakLoop)
    @Description: Manages the client-side music player with queue navigation, play/pause controls, and a topbar UI.
]]

-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

local MusicController = {
	song_queue = nil :: { Sound }?,
	current_song = nil :: Sound?,
	current_song_index = nil :: number?,
	music_changed = nil :: Signal.Signal<Sound, number>?,
	_ended_connection = nil,
	music_topbar = nil,
	menu = nil,
}

-- Types
export type MusicController = typeof(MusicController)

-- Functions
function MusicController._edit_display(self: MusicController, text: string, text_size: number, font: string)
	self.music_topbar.container:setTextFont(font)
	self.music_topbar.container:setTextSize(text_size)
	self.music_topbar.container:setLabel(text)
end

-- Functions
function MusicController.modify_queue(self: MusicController, position_shift: number)
	if not self.song_queue then
		warn("No music queue to modify.")
		return
	end

	if self.current_song then
		self.current_song:Stop()
	end

	self.current_song_index = self.current_song_index or 1

	local old_song_index = self.current_song_index
	local queue_size = #self.song_queue

	self.current_song_index = (((old_song_index + position_shift) - 1) % queue_size) + 1

	self.current_song = self.song_queue[self.current_song_index]

	self:toggle_music(true)

	self:_edit_display(` #{self.current_song_index} - {self.current_song.Name}`, 16, "Ubuntu")
end

function MusicController.toggle_music(self: MusicController, enabled: boolean)
	if not self.current_song then
		warn("No loaded song to toggle.")
		return
	end

	if self._ended_connection then
		self._ended_connection:Disconnect()
		self._ended_connection = nil
	end

	if enabled == true then
		self.current_song:Play()
		self._ended_connection = self.current_song.Ended:Connect(function()
			self:modify_queue(1)
		end)
	else
		self.current_song:Stop()
	end
end

function MusicController.set_soundtrack(self: MusicController, container: Folder?)
	if self.current_song then
		self:toggle_music(false)
	end

	if container ~= nil then
		self.song_queue = container:GetChildren()
		self:modify_queue(0)
		self.menu:unlock()
	else
		self.song_queue = nil
		self.current_song = nil
		self:_edit_display("No music playing", 16, "Ubuntu")
	end
end

function MusicController.init(self: MusicController)
	-- Create the topbar buttons
	self.music_topbar = {
		container = TopbarPlus.new(),
		rewind = TopbarPlus.new(),
		play_pause = TopbarPlus.new(),
		skip = TopbarPlus.new(),
	}

	-- Apply select/deselect images
	self.music_topbar.container:setImage(7059338404, "Deselected")
	self.music_topbar.container:setImage(7059338404, "Selected")
	self.music_topbar.rewind:setImage(12662712394)
	self.music_topbar.skip:setImage(88365123525975)
	self.music_topbar.play_pause:setImage(4458862490, "Deselected")
	self.music_topbar.play_pause:setImage(8215093320, "Selected")

	-- Merge buttons into menu
	self.menu = self.music_topbar.container:setMenu({
		self.music_topbar.rewind,
		self.music_topbar.play_pause,
		self.music_topbar.skip,
	})

	self.music_changed = Signal.new()
	self.menu:lock()

	-- Initialise clicked connections
	-- Clicked connections
	self.music_topbar.play_pause.toggled:Connect(function(state)
		self:toggle_music(not state)
	end)

	self.music_topbar.rewind.selected:Connect(function()
		self:modify_queue(-1)
	end)

	self.music_topbar.skip.selected:Connect(function()
		self:modify_queue(1)
	end)

	-- Detect when the music changes and edit the text
	self.music_changed:Connect(function(song: Sound, index: number)
		self.music_topbar.container:setTextFont("Ubuntu")
		self.music_topbar.container:setTextSize(16)
		self.music_topbar.container:setLabel(` #{index} - {song.Name}`)
	end)

	-- Load default soundtrack
	self:set_soundtrack(ReplicatedStorage.Assets.Soundtracks.Default)
end

return MusicController

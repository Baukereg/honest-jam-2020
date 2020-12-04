extends Node

onready var _music_tracks = [
#	preload("res://assets/audio/folk-round-by-kevin-macleod-from-filmmusic-io.ogg"),
#	preload("res://assets/audio/midnight-tale-by-kevin-macleod-from-filmmusic-io.ogg")
]

var _audio_stream:AudioStreamPlayer
var _current_music_track:int = -1

##
# @override
##
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	_audio_stream = AudioStreamPlayer.new()
	add_child(_audio_stream)
	_audio_stream.volume_db = Settings.music_level
	_audio_stream.connect("finished", self, "_attempt_next")
	
	if _music_tracks.size() > 0:
		_attempt_next()
	
##
# @method set_volume
# @param {float} volume
##
func set_volume(volume:float):
	_audio_stream.volume_db = volume
	
##
# @method _attempt_next
##
func _attempt_next():
	if !_audio_stream.playing:
		_current_music_track = 0 if _current_music_track != 0 else 1
		_audio_stream.stream = _music_tracks[_current_music_track]
		_audio_stream.play()
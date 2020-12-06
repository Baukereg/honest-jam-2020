extends Node

const PITCH_LERP = .002

var auto_play_next:bool = false

var _audio_stream:AudioStreamPlayer
var _playlist:Array
var _current_track:int = -1

var target_pitch = 1

##
# @override
##
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	_audio_stream = AudioStreamPlayer.new()
	add_child(_audio_stream)
	_audio_stream.volume_db = 0
	_audio_stream.connect("finished", self, "_on_track_finished")
	
	_playlist = MusicTrack.data
	
func set_pitch(pitch:float, tween:bool = false):
	target_pitch = pitch
	if !tween:
		_audio_stream.pitch_scale = target_pitch
	
func _process(delta):
	_audio_stream.pitch_scale = lerp(_audio_stream.pitch_scale, target_pitch, PITCH_LERP)
	
##
# @method set_volume
# @param {float} volume
##
func set_volume(volume:float):
	_audio_stream.volume_db = volume
	
##
# @method loop_playlist
##
func loop_playlist(from:int = 0):
	while from >= _playlist.size():
		from -= _playlist.size()
	
##
# @method attempt_next
##
func attempt_next():
	if !_audio_stream.playing:
		_current_track += 1
		if _current_track >= _playlist.size():
			_current_track = 0
			
		_audio_stream.stream = _playlist[_current_track].resource
		_audio_stream.play()
		
##
# @method _on_track_finished
##
func _on_track_finished():
	if auto_play_next:
		attempt_next()
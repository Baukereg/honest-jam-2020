extends Node

var _audio_stream:AudioStreamPlayer

##
# @override
##
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

	_audio_stream = AudioStreamPlayer.new()
	add_child(_audio_stream)
	_audio_stream.volume_db = -10

##
# @method set_volume
# @param {float} volume
##
func set_volume(volume:float):
	_audio_stream.volume_db = volume
	
##
# @method play
# @param {int} fx_id
# @param {bool} override
##
func play(fx_id:int, override:bool = true):
	if _audio_stream.playing && !override:
		return

	var fx_data = Fx.data[fx_id]
	_audio_stream.stream = fx_data.resource
	_audio_stream.play()
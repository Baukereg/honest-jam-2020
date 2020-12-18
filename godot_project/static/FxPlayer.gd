extends Node

const NUM_OF_CHANNELS = 2

var _channels:Array = []
var _selected:int = 0

##
# @override
##
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

	for i in NUM_OF_CHANNELS:
		var audio_stream = AudioStreamPlayer.new()
		add_child(audio_stream)
		audio_stream.volume_db = -10
		_channels.push_back(audio_stream)

##
# @method set_volume
# @param {float} volume
##
func set_volume(volume:float):
	for audio_stream in _channels:
		audio_stream.volume_db = volume
	
##
# @method play
# @param {int} fx_id
# @param {bool} override
##
func play(fx_id:int, override:bool = true):
	var audio_stream:AudioStreamPlayer = _channels[_selected]
	audio_stream.stop()

	var fx_data = Fx.data[fx_id]
	audio_stream.stream = fx_data.resource
	audio_stream.play()
	
	_selected += 1
	if _selected >= _channels.size():
		_selected = 0
	
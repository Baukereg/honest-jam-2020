extends MeshInstance
class_name Jukebox

const JUKEBOX_DOWN_TIME = 20
const JUKEBOX_DOWN_PITCH = .3
const SCORE_INTERVAL = 4
const MIN_SCORE = -5

var _score = -1

##
# @override
##
func _ready():
	$PuffParticles.emitting = false
	
	$DownTimer.one_shot = true
	$DownTimer.wait_time = JUKEBOX_DOWN_TIME
	$DownTimer.connect("timeout", self, "_on_down_time")
	$DownTimer.start()
	
	$ScoreTimer.connect("timeout", self, "_on_score")
	
	$SmileyParticles.draw_pass_1.material.albedo_texture = Smiley.data[Smiley.UNHAPPY].texture
	
##
# @method reset
##
func reset(stop_down_timer:bool = false):
	MusicPlayer.set_pitch(1)
	$PuffParticles.emitting = false
	$DownTimer.stop()
	$ScoreTimer.stop()
	
	if !stop_down_timer:
		$DownTimer.start()
	
##
# @method _on_down_time
##
func _on_down_time():
	MusicPlayer.set_pitch(JUKEBOX_DOWN_PITCH, true)
	$PuffParticles.emitting = true
	$ScoreTimer.start(SCORE_INTERVAL)
	
##
# @method _on_score
##
func _on_score():
	$SmileyParticles.amount = abs(_score)
	$SmileyParticles.emitting = true
	
	EventBus.publish(EventType.SCORE, {
		"score": _score
	})
	
	if _score > MIN_SCORE:
		_score -= 1
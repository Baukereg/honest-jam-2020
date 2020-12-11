extends Spatial
class_name Jukebox

const JUKEBOX_DOWN_INTERVAL = [ 20, 50 ]
const JUKEBOX_DOWN_PITCH = .5
const JUKEBOX_DOWN_LERP = .01
const JUKEBOX_UP_LERP = .05
const SCORE_INTERVAL = 4
const MIN_SCORE = -5

var _score = -1
var _active = false

##
# @override
##
func _ready():
	$PuffParticles.emitting = false
	
	$DownTimer.one_shot = true
	$DownTimer.connect("timeout", self, "_on_down_time")
	$ScoreTimer.connect("timeout", self, "_on_score")
	
	$SmileyParticles.draw_pass_1.material.albedo_texture = Smiley.data[Smiley.UNHAPPY].texture
	
##
# @method initialize
# @param {bool} active
##
func activate(active:bool):
	_active = active
	$InteractableArea/CollisionShape.disabled = !_active
	$ScoreTimer.stop()
	
	if _active:
		restart()
	else:
		$DownTimer.stop()
		MusicPlayer.set_pitch(1)
		
##
# @method _active
# @return {bool}
##
func is_active():
	return _active
	
##
# @method restart
##
func restart():
	_score = -1
	MusicPlayer.set_pitch(1, JUKEBOX_UP_LERP)
	$DownTimer.start(Utils.irand_range(JUKEBOX_DOWN_INTERVAL[0], JUKEBOX_DOWN_INTERVAL[1]))
	$ScoreTimer.stop()
	$PuffParticles.emitting = false
	$AnimationPlayer.play("play")
	
##
# @method _on_down_time
##
func _on_down_time():
	MusicPlayer.set_pitch(JUKEBOX_DOWN_PITCH, JUKEBOX_DOWN_LERP)
	$PuffParticles.emitting = true
	$ScoreTimer.start(SCORE_INTERVAL)
	$AnimationPlayer.play("down")
	
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
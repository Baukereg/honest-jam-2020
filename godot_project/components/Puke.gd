extends Spatial
class_name Puke

const SCORE_INTERVAL = 4
const CLEAN_UP_TIME = 1.5

##
# @override
##
func _ready():
	$ScoreTimer.start(SCORE_INTERVAL)
	$ScoreTimer.connect("timeout", self, "_on_score")
	
	$SmileyParticles.amount = abs(1)
	$SmileyParticles.draw_pass_1.material.albedo_texture = Smiley.data[Smiley.UNHAPPY].texture
	
	$CleanUpTween.connect("tween_all_completed", self, "_on_cleaned")
	
##
# @method _on_score
##
func _on_score():
	$SmileyParticles.emitting = true
	EventBus.publish(EventType.SCORE, {
		"score": -1
	})

##
# @method clean_up
##
func clean_up():
	$ScoreTimer.stop()
	
	$CleanUpTween.interpolate_property(
		$Mesh, "scale", Vector3.ONE, Vector3.ZERO,
		CLEAN_UP_TIME, Tween.TRANS_SINE, Tween.EASE_IN
	)
	$CleanUpTween.start()
	
##
# @method _on_cleaned
##
func _on_cleaned():
	queue_free()
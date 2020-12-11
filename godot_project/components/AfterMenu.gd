extends Control
signal completed

const MARGIN = [ Vector2(0, -600), Vector2(0, 520) ]
const DURATION = .5

var _bar_center:Vector2

##
# @override
##
func _ready():
	hide()
	_bar_center = $Bar.position
	
	$TweenIn.connect("tween_all_completed", self, "_show")
	$TweenOut.connect("tween_all_completed", self, "_complete")
	$Bar/ContinueButton.connect("pressed", self, "_continue")

##
# @method start
# @param {scores}
##
func start(scores):
	show()
	get_tree().paused = true
	$Bar/ContinueButton.disabled = true
	
	$Bar/Scores/ScorePositive.text = str(scores.positive) + "x"
	$Bar/Scores/ScoreNeutral.text = str(scores.neutral) + "x"
	$Bar/Scores/ScoreNegative.text = str(scores.negative) + "x"
	$Bar/StreakLabel.text = "Positive streak: " + str(scores.streak) + "x"
	
	$Bar.position = _bar_center + MARGIN[0]
	$TweenIn.interpolate_property(
		$Bar, "position", _bar_center + MARGIN[0], _bar_center,
		DURATION, Tween.TRANS_BACK, Tween.EASE_OUT
	)
	$TweenIn.start()
	
##
# @method _show
##
func _show():
	$Bar/ContinueButton.disabled = false
	$Bar/ContinueButton.grab_focus()
	
##
# @method _continue
##
func _continue():
	$Bar/ContinueButton.disabled = true
	
	$TweenOut.interpolate_property(
		$Bar, "position", _bar_center, _bar_center + MARGIN[1],
		DURATION, Tween.TRANS_BACK, Tween.EASE_IN
	)
	$TweenOut.start()
	
##
# @method _complete
##
func _complete():
	get_tree().paused = false
	hide()
	emit_signal("completed")

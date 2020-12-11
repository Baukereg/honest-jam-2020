extends Control
signal completed

const MARGIN = [ Vector2(0, -560), Vector2(0, 520) ]
const INIT_DELAY = .3
const DURATION = .5
const DELAY = 1

var _bar_center:Vector2

##
# @override
##
func _ready():
	hide()
	_bar_center = $Bar.position
	$Tween.connect("tween_all_completed", self, "_on_completed")
	
##
# @method start
# @param {int} day
##
func start(day:int):
	show()
	get_tree().paused = true
	$Bar/Label.text = "Day " + str(day) + "/3"
	
	$Bar.position = _bar_center + MARGIN[0]
	$Tween.interpolate_property(
		$Bar, "position", _bar_center + MARGIN[0], _bar_center,
		DURATION, Tween.TRANS_BACK, Tween.EASE_OUT, INIT_DELAY
	)
	$Tween.interpolate_property(
		$Bar, "position", _bar_center, _bar_center + MARGIN[1],
		DURATION, Tween.TRANS_BACK, Tween.EASE_IN, INIT_DELAY + DURATION + DELAY
	)
	$Tween.start()
	
##
# @method _on_completed
##
func _on_completed():
	get_tree().paused = false
	emit_signal("completed")
	hide()
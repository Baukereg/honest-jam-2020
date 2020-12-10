extends Control
signal close

onready var _continue_button:Button = $ContinueButton

##
# @override
##
func _ready():
	hide()
	
	_continue_button.text = tr("CONTINUE")
	_continue_button.connect("pressed", self, "_continue")

##
# @method start
##
func start():
	get_tree().paused = true
	_continue_button.grab_focus()
	show()
	
##
# @method _continue
##
func _continue():
	get_tree().paused = false
	hide()
	emit_signal("close")
extends Node2D

const EXCLUDE_CHARACTERS = [ " ", "/", "#", "<", ">", "*" ]

func _ready():
	$Menu/ScoreLabel.text = str(Session.last_score)
	
	$Menu/NameEdit.text = Settings.username
	$Menu/NameEdit.connect("focus_exited", self, "_on_name_changed")
	$Menu/NameEdit.grab_focus()
	$Menu/SubmitButton.connect("pressed", self, "_submit")
	$Menu/RetryButton.connect("pressed", self, "_retry")
	$Menu/MainMenuButton.connect("pressed", self, "_back_to_main_menu")
	
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	
##
# @method _on_name_changed
##
func _on_name_changed():
	var name:String = $Menu/NameEdit.text
	for character in EXCLUDE_CHARACTERS:
		name = name.replace(character, "")
	$Menu/NameEdit.text = name
	
##
# @method _submit
##
func _submit():
	var name:String = $Menu/NameEdit.text
	if name == "":
		return
		
	$Menu/NameEdit.editable = false
	$Menu/NameEdit.focus_mode = Control.FOCUS_NONE
	$Menu/SubmitButton.disabled = true
	$Menu/SubmitButton.focus_mode = Control.FOCUS_NONE
	$Menu/RetryButton.disabled = true
	$Menu/RetryButton.focus_mode = Control.FOCUS_NONE
	$Menu/MainMenuButton.disabled = true
	$Menu/MainMenuButton.focus_mode = Control.FOCUS_NONE
	
	Settings.username = name
	$HTTPRequest.request(Constant.DREAMLO_SUBMIT_URL + name + "/" + str(Session.last_score))
	
##
# @method _on_request_completed
# @Override
##
func _on_request_completed(result, response_code, headers, body):
	_back_to_main_menu()
		
##
# @method _retry
##
func _retry():
	get_tree().change_scene("res://scenes/game/Game.tscn")
		
##
# @method _back_to_main_menu
##
func _back_to_main_menu():
	get_tree().change_scene("res://scenes/main_menu/MainMenu.tscn")
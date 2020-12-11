extends Node2D

func _ready():
	$Menu/ScoreLabel.text = str(Session.last_score)
	if !Session.last_personal_best:
		$Menu/HighscoreLabel.hide()
		
	$Menu/RetryButton.connect("pressed", self, "_retry")
	$Menu/MainMenuButton.connect("pressed", self, "_back_to_main_menu")
		
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
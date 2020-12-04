extends Node2D

onready var _title_label:Button = $Menu/TitleLabel
onready var _start_button:Button = $Menu/StartButton
onready var _fullscreen_checkbox = $Menu/FullscreenCheckbox
onready var _music_slider = $Menu/MusicContainer/MusicSlider
onready var _quit_button:Button = $Menu/QuitButton

##
# @override
##
func _ready():
	_start_button.grab_focus()
	_start_button.connect("pressed", self, "_start_game")
	
	_fullscreen_checkbox.pressed = Settings.fullscreen
	OS.window_fullscreen = Settings.fullscreen
	_fullscreen_checkbox.connect("pressed", self, "_toggle_fullscreen")
	
	_music_slider.value = Settings.music_level
	_music_slider.connect("value_changed", self, "_set_music_volume")
	
	_quit_button.connect("pressed", self, "_quit_game")
	
##
# @method _start_game
##
func _start_game():
	pass #get_tree().change_scene("res://scenes/game/Game.tscn")

##
# @method _toggle_fullscreen
##
func _toggle_fullscreen():
	Settings.fullscreen = _fullscreen_checkbox.pressed
	OS.window_fullscreen = Settings.fullscreen
	
##
# @method _set_music_volume
# @param {float} volume
##
func _set_music_volume(volume:float):
	Settings.music_level = volume
	MusicPlayer.set_volume(volume)
	
##
# @method _quit_game
##
func _quit_game():
	get_tree().quit()
	
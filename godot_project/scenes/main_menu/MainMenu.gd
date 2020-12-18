extends Node2D
 
##
# @override
##
func _ready():
	$CanvasLayer/Menu/StartButton.grab_focus()
	$CanvasLayer/Menu/StartButton.connect("pressed", self, "_start_game")
	$CanvasLayer/Menu/ChilloutButton.connect("pressed", self, "_chillout")
	$CanvasLayer/Menu/QuitButton.connect("pressed", self, "_quit_game")
	
	OS.window_fullscreen = Settings.fullscreen
	$CanvasLayer/Menu/FullscreenCheckbox.pressed = Settings.fullscreen
	$CanvasLayer/Menu/FullscreenCheckbox.connect("pressed", self, "_toggle_fullscreen")
	
	$CanvasLayer/Menu/TutorialCheckbox.pressed = Settings.tutorial_unabled
	$CanvasLayer/Menu/TutorialCheckbox.connect("pressed", self, "_toggle_tutorial")
	
	$CanvasLayer/Menu/MusicVolumeSlider.value = Settings.music_volume
	$CanvasLayer/Menu/MusicVolumeSlider.connect("value_changed", self, "_set_music_volume")
	
	# Set items of language drop down.
	var num_of_languages = Language.data.size()
	for i in num_of_languages:
		var language_data = Language.data[i]
		if !language_data.enabled:
			continue
		$CanvasLayer/Menu/LanguageDropdown.add_item(language_data.name, i)
	
	$CanvasLayer/Menu/LanguageDropdown.select($CanvasLayer/Menu/LanguageDropdown.get_item_index(Settings.language))
	$CanvasLayer/Menu/LanguageDropdown.connect("item_selected", self, "_set_language")
	_set_language(Settings.language)
	
	$CanvasLayer/Menu/InputDeviceDropdown.connect("item_selected", self, "_set_input_device")
	
	MusicPlayer.set_volume(Settings.music_volume)
	MusicPlayer.play_track(MusicTrack.SURF_SHIMMY)
	FxPlayer.set_volume(Settings.music_volume)
	
	$CanvasLayer/Leaderboard.get_scores(5)

##
# @method _start_game
##
func _start_game():
	get_tree().change_scene("res://scenes/game/Game.tscn")

##
# @method _chillout
##
func _chillout():
	get_tree().change_scene("res://scenes/chillout/Chillout.tscn")

##
# @method _quit_game
##
func _quit_game():
	get_tree().quit()

##
# @method _toggle_fullscreen
##
func _toggle_fullscreen():
	OS.window_fullscreen = $CanvasLayer/Menu/FullscreenCheckbox.pressed
	Settings.fullscreen = OS.window_fullscreen
	
##
# @method _toggle_tutorial
##
func _toggle_tutorial():
	Settings.tutorial_unabled = $CanvasLayer/Menu/TutorialCheckbox.pressed
	
##
# @method _set_music_volume
# @param {float} volume
##
func _set_music_volume(volume:float):
	Settings.music_volume = volume
	MusicPlayer.set_volume(volume)
	FxPlayer.set_volume(volume)
		
##
# @method _set_language
# @param {int} idx
##
func _set_language(idx:int):
	var id = $CanvasLayer/Menu/LanguageDropdown.get_item_id(idx)
	Settings.language = id
	TranslationServer.set_locale(Language.data[id].code)
	
	$CanvasLayer/Menu/StartButton.text = tr("SCORE_ATTACK")
	$CanvasLayer/Menu/ChilloutButton.text = tr("CHILLOUT")
	$CanvasLayer/Menu/QuitButton.text = tr("QUIT")
	$CanvasLayer/Menu/FullscreenCheckbox.text = tr("FULLSCREEN")
	$CanvasLayer/Menu/TutorialCheckbox.text = tr("TUTORIAL_ENABLE")
	$CanvasLayer/Menu/MusicVolumeLabel.text = tr("MUSIC_VOLUME")
	
	# Set items of input device drop down.
	$CanvasLayer/Menu/InputDeviceDropdown.clear()
	var num_of_devices = InputDevice.data.size()
	for i in num_of_devices:
		var device_data = InputDevice.data[i]
		if !device_data.enabled:
			continue
		$CanvasLayer/Menu/InputDeviceDropdown.add_item(tr(device_data.tr), i)
	
	$CanvasLayer/Menu/InputDeviceDropdown.select($CanvasLayer/Menu/InputDeviceDropdown.get_item_index(Settings.input_device))
		
##
# @method _set_input_device
# @param {int} idx
##
func _set_input_device(idx:int):
	var id = $CanvasLayer/Menu/InputDeviceDropdown.get_item_id(idx)
	Settings.input_device = id

extends Node

enum {
	SURF_SHIMMY,
	HAPPY_SONG,
}

onready var data = [
	{
		"name": "Surf Shimy",
		"author": "Kevin MacLeod",
		"resource": preload("res://assets/audio/music/surf-shimmy.ogg")
	},
	{
		"name": "Happy Song",
		"author": "TazLazuli",
		"resource": preload("res://assets/audio/music/happy-song.ogg")
	},
]
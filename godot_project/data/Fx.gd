extends Node

enum {
	BEER,
	CAT,
	COINS,
	CORK,
	GROAN,
	KICK,
	MOUSE,
	POUR,
	WIPE,
	BELL,
	VOMIT
}

onready var data = [
	{
		"resource": preload("res://assets/audio/fx/beer_bottle.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/cat.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/coins.ogg")
	},
	{
		"resource": preload("res://assets/audio/fx/cork.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/groan.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/kick.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/mouse.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/pour.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/wipe.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/bell.wav")
	},
	{
		"resource": preload("res://assets/audio/fx/vomit.wav")
	}
]
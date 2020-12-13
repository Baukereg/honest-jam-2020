extends Node

enum {
	BEER_TAP,
	COFFEE_MACHINE,
	CUSTOMER,
	JUKEBOX,
	PUKE,
	MOUSE,
	ARCADE,
	CAT,
	WINE_RACK,
	CAT_PET,
}

onready var data = [
	{
		"text": "BEER_TAP",
		"icon": preload("res://assets/UI/ui_beer.png"),
	},
	{
		"text": "COFFEE_MACHINE",
		"icon": preload("res://assets/UI/ui_coffee.png"),
	},
	{
		"text": "SERVE",
	},
	{
		"text": "KICK_JUKEBOX",
		"icon": preload("res://assets/UI/kick_icon.png"),
	},
	{
		"text": "CLEAN",
		"icon": preload("res://assets/UI/puke_icon.png"),
	},
	{
	},
	{
		"text": "KICK_GAMER",
		"icon": preload("res://assets/UI/kick_icon.png"),
	},
	{
	},
	{
		"text": "WINE_RACK",
		"icon": preload("res://assets/UI/ui_wine.png"),
	},
	{
		"text": "PET_CAT",
		"icon": preload("res://assets/UI/cat_icon.png"),
	},
]

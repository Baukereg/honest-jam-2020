extends Node

onready var data = [
	{
		"spawn_time": [ 10, 6 ],
		"max_customers": 3,
		"enabled_interacts": [
			Interact.JUKEBOX,
		],
	},
	{
		"spawn_time": [ 8, 4 ],
		"max_customers": 4,
		"enabled_interacts": [
			Interact.ARCADE,
			Interact.JUKEBOX,
			Interact.PUKE,
		],
	},
	{
		"spawn_time": [ 6, 3 ],
		"max_customers": 5,
		"enabled_interacts": [
			Interact.ARCADE,
			Interact.JUKEBOX,
			Interact.MOUSE,
			Interact.PUKE,
		],
	},
	{
		"spawn_time": [ 4, 2 ],
		"max_customers": 6,
		"enabled_interacts": [
			Interact.ARCADE,
			Interact.CAT,
			Interact.JUKEBOX,
			Interact.MOUSE,
			Interact.PUKE,
		],
	},
	{
		"spawn_time": [ 3, 1 ],
		"max_customers": 99,
		"enabled_interacts": [
			Interact.ARCADE,
			Interact.CAT,
			Interact.JUKEBOX,
			Interact.MOUSE,
			Interact.PUKE,
		],
	}
]

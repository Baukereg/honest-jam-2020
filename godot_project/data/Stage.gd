extends Node

enum {
	ONE,
	TWO,
	THREE,
}

onready var data = [
	{
		"spawn_time": [ 10, 4 ],
		"max_customers": 3,
		"enabled_interacts": [
			Interact.JUKEBOX,
			Interact.PUKE,
		],
	},
	{
		"spawn_time": [ 7, 3 ],
		"max_customers": 5,
		"enabled_interacts": [
			Interact.ARCADE,
			Interact.JUKEBOX,
			Interact.MOUSE,
			Interact.PUKE,
		],
	},
	{
		"spawn_time": [ 4, 1 ],
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

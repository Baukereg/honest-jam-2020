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
			Interact.ARCADE,
			Interact.CAT,
			Interact.JUKEBOX,
			Interact.MOUSE,
			Interact.PUKE,
		],
	},
	{
		"spawn_time": [ 8, 2 ],
		"max_customers": 4,
		"enabled_interacts": [
			Interact.ARCADE,
			Interact.CAT,
		],
	},
	{
		"spawn_time": [ 4, 1 ],
		"max_customers": 5,
		"enabled_interacts": [
			Interact.CAT,
		],
	}
]

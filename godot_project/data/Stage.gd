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
		"disabled_interacts": [
			Interact.MOUSE,
			Interact.ARCADE,
			Interact.DOG,
		],
	},
	{
		"spawn_time": [ 8, 2 ],
		"max_customers": 4,
		"disabled_interacts": [
			Interact.ARCADE,
			Interact.DOG,
		],
	},
	{
		"spawn_time": [ 4, 1 ],
		"max_customers": 5,
		"disabled_interacts": [
			Interact.DOG,
		],
	}
]

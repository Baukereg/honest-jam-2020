extends Node

enum {
	ACTOR_0,
	ACTOR_1,
	ACTOR_2,
}

onready var data = [
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_0.tres"),
		"consumes": [ Consumable.BEER ],
		"num_of_consumes": [ 2, 3 ],
		"consume_time": 6,
		"wait_times": [ 4, 8 ],
		"scores": [ -1, 1, 2 ],
		"puke_chance": .6,
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_1.tres"),
		"consumes": [ Consumable.COFFEE, Consumable.BEER, Consumable.WINE ],
		"num_of_consumes": [ 1, 2 ],
		"consume_time": 10,
		"wait_times": [ 4, 12 ],
		"scores": [ -1, 1, 3 ],
		"puke_chance": .2,
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_2.tres"),
		"consumes": [ Consumable.COFFEE ],
		"num_of_consumes": [ 1 ],
		"consume_time": 20,
		"wait_times": [ 8, 20 ],
		"scores": [ 1, 3, 5 ],
		"puke_chance": 0,
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_3.tres"),
		"consumes": [ Consumable.BEER, Consumable.WINE ],
		"num_of_consumes": [ 2, 3 ],
		"consume_time": 6,
		"wait_times": [ 8, 14 ],
		"scores": [ -3, 1, 2 ],
		"puke_chance": .6,
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_4.tres"),
		"consumes": [ Consumable.WINE ],
		"num_of_consumes": [ 1, 2 ],
		"consume_time": 15,
		"wait_times": [ 8, 16 ],
		"scores": [ 0, 1, 3 ],
		"puke_chance": 0,
	}
]

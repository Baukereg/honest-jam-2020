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
		"wait_times": [ 3, 10 ],
		"scores": [ -3, 0, 2 ],
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_1.tres"),
		"consumes": [ Consumable.COFFEE, Consumable.BEER ],
		"num_of_consumes": [ 1, 2 ],
		"consume_time": 10,
		"wait_times": [ 4, 10 ],
		"scores": [ -1, 1, 3 ],
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_2.tres"),
		"consumes": [ Consumable.COFFEE ],
		"num_of_consumes": [ 1 ],
		"consume_time": 20,
		"wait_times": [ 8, 20 ],
		"scores": [ 1, 3, 5 ],
	}
]
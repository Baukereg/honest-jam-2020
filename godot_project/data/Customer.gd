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
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_1.tres"),
		"consumes": [ Consumable.COFFEE, Consumable.BEER ],
		"num_of_consumes": [ 1, 2 ],
		"consume_time": 10,
	},
	{
		"mesh": preload("res://assets/3D/meshes/mesh_customer_2.tres"),
		"consumes": [ Consumable.COFFEE ],
		"num_of_consumes": [ 1 ],
		"consume_time": 16,
	}
]
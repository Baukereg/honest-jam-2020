extends Node

enum {
	COFFEE,
	BEER,
}

onready var data = [
	{
		"name": "COFFEE",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_coffee.tres"),
	},
	{
		"name": "BEER",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_beer.tres"),
	}
]
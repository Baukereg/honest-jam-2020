extends Node

enum {
	COFFEE,
	BEER,
	WINE,
}

onready var data = [
	{
		"name": "COFFEE",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_coffee.tres"),
	},
	{
		"name": "BEER",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_beer.tres"),
	},
	{
		"name": "WINE",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_wine.tres"),
	}
]
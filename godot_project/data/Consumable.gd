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
		"icon": preload("res://assets/UI/ui_coffee.png"),
	},
	{
		"name": "BEER",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_beer.tres"),
		"icon": preload("res://assets/UI/ui_beer.png"),
	},
	{
		"name": "WINE",
		"mesh": preload("res://assets/3D/meshes/mesh_consumable_wine.tres"),
		"icon": preload("res://assets/UI/ui_wine.png"),
	}
]
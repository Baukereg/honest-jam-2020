extends Node

enum {
	PATH_WINDOW_0,
	PATH_ARCADE_1,
	PATH_TABLE_0,
	PATH_TABLE_1,
	PATH_TABLE_2,
}

onready var data = [
	{
		"nodes": [ 2, 11, 3, 4 ]
	},
	{
		"nodes": [ 2, 11, 5 ]
	},
	{
		"nodes": [ 0, 1, 7 ]
	},
	{
		"nodes": [ 0, 1, 6, 8 ]
	},
	{
		"nodes": [ 0, 1, 9, 10 ]
	},
	{
		"nodes": [ 0, 1, 12, 13 ],
		"customer_option_id": CustomerOption.ARCADE
	},
]
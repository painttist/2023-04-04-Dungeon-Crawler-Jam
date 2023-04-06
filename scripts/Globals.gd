extends Node

enum {
	ARROW,
	SWORD,
}

const tiles = [
	[[SWORD, SWORD], [ARROW, null]],
	[[ARROW, ARROW], [null, null]]
]

var sprite_dict = {
	ARROW: preload("res://Sprites/sword.png"),
	SWORD: preload("res://Sprites/sword.png"),
}

func get_rand_tile_set():
	return tiles[randi() % tiles.size()]

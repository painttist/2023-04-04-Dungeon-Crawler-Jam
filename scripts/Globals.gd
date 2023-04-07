extends Node


var is_mouse_inside_inventory: bool = false

enum {
	ARROW,
	SWORD,
}

const tiles = [
	[[SWORD, SWORD], [ARROW, null]],
	[[ARROW, ARROW], [null, null]]
]

var sprite_dict = {
	ARROW: preload("res://Sprites/arrow_up.png"),
	SWORD: preload("res://Sprites/sword.png"),
}

func get_rand_tile_set():
	return tiles[randi() % tiles.size()]

var enemy_actions_stack: Array[Callable] = [
	#func (): await get_tree().create_timer(2.0).timeout
	]
var enemy_action_running = false

func enemy_add_action(action: Callable):
	enemy_actions_stack.push_back(action)

func player_ready() -> bool:
	return not enemy_action_running && enemy_actions_stack.is_empty()

func _process(_delta):
	if not enemy_actions_stack.is_empty() and not enemy_action_running:
		enemy_action_running = true
		await enemy_actions_stack.pop_front().call()
		enemy_action_running = false

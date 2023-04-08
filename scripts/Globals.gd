extends Node


var is_mouse_inside_inventory: bool = false

enum {
#	NONE, # use null instead
	ARROW,
	LEFT,
	RIGHT,
	SWORD_UP,
	SWORD_DOWN,
	KNIFE,
	WAND_UP,
	WAND_DOWN,
	POTION,
	SHIELD,
	KEY
}

const tiles = [
	[[SWORD_UP, ARROW], [SWORD_DOWN, null]],
	[[ARROW, ARROW], [null, null]],
	[[WAND_UP, null], [WAND_DOWN, null]],
]

# behaviours
enum {
	MOVE_FORWARD,
	MOVE_BACK,
	MOVE_LEFT,
	MOVE_RIGHT,
	TURN_LEFT,
	TURN_RIGHT,
	ATTACK_KNIFE,
	ATTACK_WAND,
	ATTACK_SWORD,
	ATTACK_BROKEN_SWORD,
	ATTACK_BROKEN_WAND,
	DRINK_POTION,
	DEFEND_SHIELD,
	USE_KEY
}

var sprite_dict = {
	ARROW: preload("res://Sprites/arrow_up_clean.png"),
	SWORD_UP: preload("res://Sprites/sword_up_clean.png"),
	SWORD_DOWN: preload("res://Sprites/sword_down_clean.png"),
	WAND_UP: preload("res://Sprites/wand_up_clean.png"),
	WAND_DOWN: preload("res://Sprites/wand_down_clean.png"),
	LEFT: preload("res://Sprites/turn_left_clean.png"),
	RIGHT: preload("res://Sprites/turn_right_clean.png"),
	KNIFE: preload("res://Sprites/sword_clean.png"),
	POTION: preload("res://Sprites/potion_clean.png")
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

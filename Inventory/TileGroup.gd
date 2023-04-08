extends Area2D

class_name TileGroup


var group = [
	[null, null],
	[null, null]
]

var tiles: Array[Tile]
var is_dragging: bool = false
var drag_offset: Vector2
var original_pos: Vector2
const drag_preview = preload("res://Inventory/TileGroupPreview.tscn")

@onready var skill_ui: SkillUI = get_parent()
@onready var player: Player = get_parent().get_parent()

func init():
#	print("Init Tilegroup")
	var children = get_children()
	for child in children:
		if child is Tile:
			tiles.append(child)
	group = Globals.get_rand_tile_set()
	update_tiles()

# Called when the node enters the scene tree for the first time.
func _ready():
	init()
#	add_to_group("Loot")

func rotate_left():
	var new_group = [
		[group[0][1], group[1][1]],
		[group[0][0], group[1][0]]
	]
	group = new_group
	merge_null_in_group()
	update_tiles()
	for tile in tiles:
		tile.rotate_left()

	
func rotate_right():
	var new_group = [
		[group[1][0], group[0][0]],
		[group[1][1], group[0][1]]
	]
	group = new_group
	merge_null_in_group()
	update_tiles()	
	for tile in tiles:
		tile.rotate_right()
		
func merge_null_in_group():
	if group[0][0] == null and group[0][1] == null:
		group[0][0] = group[1][0]
		group[0][1] = group[1][1]
		group[1][0] = null
		group[1][1] = null
	elif group[0][0] == null and group[1][0] == null:
		group[0][0] = group[0][1]
		group[1][0] = group[1][1]
		group[0][1] = null
		group[1][1] = null	
	
func update_tiles():
	# update tiles
	var tile_counter = 0
	for row in range(2):
		for col in range(2):
#			print(group[row][col])
			tiles[tile_counter].set_item_type(group[row][col])
			tile_counter += 1

#func _input(event):
#	if event.is_action_pressed("A"):
#		rotate_left()
#	elif event.is_action_pressed("D"):
#		rotate_right()

func _process(delta):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		self.position = mouse_pos - drag_offset
	
func _input_event(viewport, event, shape_idx):
#	print("global pos:", event.position, "\tself position", self.transform.origin)
	if event is InputEventMouseButton and event.is_action_pressed("LeftMouse"):
		var local_pos = event.position - self.transform.origin
#		print("local_pos", local_pos, ", ", shape_idx)
		# init dragging
		if !is_dragging and is_valid_position(local_pos):
			print("start drag")
			is_dragging = true
			# event.position is dragging offset
			drag_offset = local_pos
			original_pos = self.global_position 
			self.input_pickable = false
		elif is_dragging:
			print("return animation")
			is_dragging = false
			position = original_pos	# TODO: animation
			self.input_pickable = true

func is_valid_position(pos: Vector2) -> bool:
	print("check valid position", pos)
	var row = int(pos.y) / 100	# HardCode: size of one tile
	var col = int(pos.x) / 100
	return group[row][col] != null

func _on_inventory_drop_area_clicked(inventory: Inventory, event_position: Vector2):
#	print("drop, event_position: ", event_position)
	if is_dragging:
		is_dragging = false
		var slot_col = int(event_position.x) / 100 - int(drag_offset.x) / 100
		var slot_row = int(event_position.y) / 100 - int(drag_offset.y) / 100
		var slot_id = slot_row * 3 + slot_col
		if inventory.check_availble_for_place(slot_id, self):
			print("drop")
			inventory.handle_drop_placement(slot_id, self)
			position = original_pos
#			self.visible = false
			self.input_pickable = true
			
			# restore player action
			skill_ui.visible = false
			player.is_picking_skills = false
		else:
			print("return by drop")
			position = original_pos
			drag_offset = Vector2.ZERO
			self.input_pickable = true

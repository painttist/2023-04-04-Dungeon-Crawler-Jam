extends GridContainer

class_name TileGroup

var group = [
	[null, null],
	[null, null]
]

var tiles: Array[Tile]

func init():
	var children = get_children()
	for child in children:
		if child is Tile:
			tiles.append(child)
	group = Globals.get_rand_tile_set()
	update_tiles()

# Called when the node enters the scene tree for the first time.
func _ready():
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _get_drag_data(at_position: Vector2): 
	print("get drag data: ", at_position)
	var preview = TextureRect.new()
	preview.texture = preload("res://Sprites/sword.png")
	set_drag_preview(preview)
	return self

func rotate_left():
	var new_group = [
		[group[0][1], group[1][1]],
		[group[0][0], group[1][0]]
	]
	group = new_group

	update_tiles()

#	for tile in tiles:
#		tile.rotate_left()

	
func rotate_right():
	var new_group = [
		[group[1][0], group[0][0]],
		[group[1][1], group[0][1]]
	]
	group = new_group
	
	for tile in tiles:
		tile.rotate_right()

#	update_tiles() # TODO: not sure what rotation doesnt work
		
func update_tiles():
	# update tiles
	var tile_counter = 0
	for row in range(2):
		for col in range(2):
#			print(group[row][col])
			tiles[tile_counter].set_item_type(group[row][col])
			tile_counter += 1

func _input(event):
	if event.is_action_pressed("A"):
		rotate_left()
	elif event.is_action_pressed("D"):
		rotate_right()
	

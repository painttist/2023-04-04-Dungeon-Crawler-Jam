extends TextureRect



# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _get_drag_data(at_position: Vector2): 
	print("get drag data: ", at_position)
	var preview = TextureRect.new()
	preview.texture = preload("res://Sprites/sword.png")
	set_drag_preview(preview)
	return self

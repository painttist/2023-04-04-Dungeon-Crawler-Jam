extends Node2D

var drag_offset: Vector2
var sprite_offset: Vector2 = Vector2(50.0, 50.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_viewport().get_mouse_position() - drag_offset + sprite_offset
	if Input.is_action_just_released("LeftMouse"):
		queue_free()

extends AudioStreamPlayer

@onready var sfx_pickup = preload("res://Audio/pickup.mp3")
@onready var sfx_place = preload("res://Audio/place.mp3")

func _on_tile_group_start_drag():
	self.stream = sfx_pickup
	self.play()


func _on_tile_group_drop():
	self.stream = sfx_place
	self.play()

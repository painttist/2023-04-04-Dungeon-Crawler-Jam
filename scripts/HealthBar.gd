extends Node2D

func _ready():
	var i = 0;
	for child in get_children():
		if child is Sprite2D:
			child.transform.origin.x = 66 + (66.0 + 10.0) * i
			i += 1
		


func _on_player_health_changed(health):
#	print("_on_player_health_changed health: ", health)
	var i = 0
	for child in get_children():
		if child is Sprite2D:
			i += 1
			if i > health:
				child.visible = false
			else:
				child.visible = true

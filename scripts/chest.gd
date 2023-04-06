extends StaticBody3D

@onready var player = get_parent().get_node("player")

func _physics_process(delta):
	look_at(player.position)

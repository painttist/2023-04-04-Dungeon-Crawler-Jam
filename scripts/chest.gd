extends StaticBody3D

@onready var player = get_parent().get_node("player")

func _physics_process(delta):
	look_at(player.position)

var health = 10

func take_damage(attacker, damage):
	health -= damage
	attacker.move_back()
	print("chest health: ", health)
	check_death()

func check_death():
	if health <= 0:
		self.queue_free()

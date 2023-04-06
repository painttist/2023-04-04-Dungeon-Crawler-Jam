extends StaticBody3D

@onready var player = get_parent().get_node("Player")

func _physics_process(delta):
	look_at(player.position)

var health = 10

func take_damage(attacker : Player, damage):
	health -= damage
	print("chest health: ", health)
	check_death()

func check_death():
	if health <= 0:
		self.queue_free()

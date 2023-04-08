extends StaticBody3D

@onready var player : Player = get_parent().get_node("Player")
@onready var reward = [[Globals.KNIFE, Globals.RIGHT], [Globals.ARROW, null]]

func picked_up(player):
	print("picked up")
	player.get_reward(reward)
	self.queue_free()

const ROTATION_SPEED = 8.0

func _physics_process(delta):
	if not player is Player:
		return
	look_at_player_smooth(delta)
	
func look_at_player_smooth(delta):
	var current_rot = transform.basis.get_rotation_quaternion().normalized()
	var look_at_rot = transform.looking_at(player.position).basis.get_rotation_quaternion().normalized()
	
	transform.basis = Basis(current_rot.slerp(look_at_rot, delta * ROTATION_SPEED))

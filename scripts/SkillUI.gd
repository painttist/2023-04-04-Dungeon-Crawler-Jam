extends CanvasLayer

class_name SkillUI

@onready var tile_group: TileGroup = $TileGroup 

func update_reward(reward):
	print("update reward: ", reward)
	tile_group.visible = true
	tile_group.group = reward
	tile_group.update_tiles()
	tile_group.reset_rotation()



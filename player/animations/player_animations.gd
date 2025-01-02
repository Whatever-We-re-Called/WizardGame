extends Node

@onready var player = get_parent() as Player

# TODO I will work on getting this working while I am refactoring
# everything else.

func _ready():
	_setup_movement_animations()
	_setup_jump_animations()


func _setup_movement_animations():
	pass


func _setup_jump_animations():
	pass
	#player.controller.jumped.connect(
		#func():
			#_set_animation("jump", false)
	#)


func _process(delta: float):
	_handle_movement_animations()


func _handle_movement_animations():
	pass


func _set_animation(animation_name: String, loop: bool, track_id: int = 0):
	player.sprite.get_animation_state().set_animation(animation_name, loop, track_id)

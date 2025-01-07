class_name AnimationControllerComponent extends Node


@rpc("any_peer", "call_local", "reliable")
func handle_movement_animation(body_node_path: NodePath, move_direction: float):
	# TODO
	_handle_horizontal_flip(_get_body_node(body_node_path), move_direction)


func _handle_horizontal_flip(body: CharacterBody2D, move_direction: float):
	if move_direction != 0:
		body.sprite.scale.x = 1 if move_direction > 0 else -1


func _get_body_node(body_node_path: NodePath) -> CharacterBody2D:
	return get_node(body_node_path)

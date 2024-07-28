class_name AbilityExecution extends Node2D


@rpc("any_peer", "call_local")
func _on_button_down(executor_peer_id: int):
	pass


@rpc("any_peer", "call_local")
func _on_button_up(executor_peer_id: int):
	pass


@rpc("any_peer", "call_local")
func _on_button_hold(executor_peer_id: int):
	pass

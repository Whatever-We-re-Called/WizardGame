extends Node


#func add_node(node_path: String):
	#_execute_add_node.rpc(node_path)
#
#
#@rpc("any_peer", "call_local", "reliable")
#func _execute_add_node(node_path: String):
	#if not multiplayer.is_server(): return
	#
	#var new_node = load(node_path).instantiate()
	#
	#pass
#
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

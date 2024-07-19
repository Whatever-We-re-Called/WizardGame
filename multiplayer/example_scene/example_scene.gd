extends Node2D


func _ready():
	SessionManager.session_added.connect(_add_player)
	SessionManager.serverbound_client_disconnected.connect(_remove_player)
	SessionManager.server_closed.connect(_server_closed)
	

func _add_player(data):
	if multiplayer.is_server():
		var player = preload("res://multiplayer/example_scene/player/player.tscn").instantiate()
		player.name = str(data.peer_id)
		$Players.add_child(player, true)


func _remove_player(id):
	for child in $Players.get_children():
		if child.name == str(id):
			child.queue_free()


func _server_closed():
	for child in $Players.get_children():
		child.queue_free()

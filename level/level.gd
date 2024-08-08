class_name Level extends Node

@export var spawn_points: SpawnPoints

var game_manager: GameManager


func _ready() -> void:
	teleport_players_to_random_spawn_points()
	_handle_server_setup()


func _handle_server_setup():
	if not multiplayer.is_server(): return
	
	teleport_players_to_random_spawn_points()


func teleport_players_to_random_spawn_points():
	if not multiplayer.is_server(): return
	
	print("A")
	var players = game_manager.get_players()
	var spawn_locations = spawn_points.get_random_list_of_spawn_locations(players.size(), true)
	for i in range(players.size()):
		print("B")
		var player = players[i]
		player.teleport.rpc_id(player.peer_id, spawn_locations[i])

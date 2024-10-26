class_name PlayableScene extends Node

@export var spawn_points: SpawnPoints

var game_manager: GameManager


@rpc("any_peer", "call_local")
func teleport_players_to_random_spawn_points():
	if not multiplayer.is_server(): return
	
	var players = game_manager.players
	var spawn_locations = spawn_points.get_random_list_of_spawn_locations(players.size(), true)
	for i in range(players.size()):
		var player = players[i]
		player.teleport(spawn_locations[i])


@rpc("any_peer", "call_local")
func teleport_player_to_random_spawn_point(player: Player):
	var spawn_location = spawn_points.get_random_spawn_location()
	player.teleport.rpc_id(player.peer_id, spawn_location)

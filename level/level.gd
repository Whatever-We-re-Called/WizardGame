class_name Level extends Node

@export var spawn_points: SpawnPoints

var game_manager: GameManager


func _ready() -> void:
	teleport_players_to_random_spawn_points()


func teleport_players_to_random_spawn_points():
	var players = game_manager.get_players()
	var spawn_locations = spawn_points.get_random_list_of_spawn_locations(players.size(), true)
	for i in range(players.size()):
		players[i].global_position = spawn_locations[i]

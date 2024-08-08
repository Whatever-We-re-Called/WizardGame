class_name GameManager extends Node

@export var temp_level_pool: Array[PackedScene]

@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner
@onready var players_root: Node = %PlayersRoot
@onready var scene_spawner: MultiplayerSpawner = %SceneSpawner
@onready var active_scene_root: Node = %ActiveSceneRoot

var players: Array[Player]:
	get:
		var result: Array[Player]
		for child in players_root.get_children():
			if child is Player: result.append(child)
		return result
var active_scene: PlayableScene:
	get:
		for child in active_scene_root.get_children():
			if child is PlayableScene: return child
		return null


const PLAYER_SCENE = preload("res://player/player.tscn")


func _ready() -> void:
	SessionManager.session_added.connect(_add_player)
	SessionManager.serverbound_client_disconnected.connect(_remove_player)
	SessionManager.server_closed.connect(_server_closed)
	
	for data in SessionManager.connected_clients.values():
		_add_player(data)
	
	_change_to_playable_scene.rpc_id(1, "res://game/wait_lobby/wait_lobby.tscn")


func _add_player(data):
	if multiplayer.is_server():
		var player = PLAYER_SCENE.instantiate()
		player.name = str(data.peer_id)
		player.peer_id = data.peer_id
		players_root.add_child(player, true)
		
		if data.has("device_ids"):
			player.set_device(data.device_ids)
		
		teleport_player_to_random_spawn_point.rpc_id(1, data.peer_id)
		_handle_add_player_signals.rpc()


@rpc("any_peer", "call_local")
func _handle_add_player_signals():
	for player in players:
		player.received_debug_input.connect(_handle_player_debug_input)


func _remove_player(id):
	for child in players_root.get_children():
		if child.name == str(id):
			child.queue_free()


func _server_closed():
	for child in players_root.get_children():
		child.queue_free()


func get_player_from_peer_id(peer_id: int) -> Player:
	for child in players_root.get_children():
		if child is Player and child.peer_id == peer_id:
			return child
	
	return null


@rpc("any_peer", "call_local")
func load_random_level():
	randomize()
	var rng = RandomNumberGenerator.new()
	var chosen_level = temp_level_pool[rng.randi_range(0, temp_level_pool.size() - 1)]
	
	_change_to_playable_scene.rpc_id(1, chosen_level.resource_path)


@rpc("any_peer", "call_local")
func _change_to_playable_scene(new_level_resource_path: String):
	_clear_active_scene.rpc()
	var new_active_scene = load(new_level_resource_path).instantiate()
	new_active_scene.game_manager = self
	active_scene_root.add_child(new_active_scene, true)


@rpc("any_peer", "call_local")
func _clear_active_scene():
	for child in active_scene_root.get_children():
		child.queue_free()


@rpc("any_peer", "call_local")
func teleport_player_to_random_spawn_point(peer_id: int):
	var target_player = get_player_from_peer_id(peer_id)
	var spawn_location = get_tree().get_first_node_in_group("spawn_points").get_random_spawn_location()
	target_player.teleport.rpc_id(peer_id, spawn_location)


func _handle_player_debug_input(debug_value: int) -> void:
	match debug_value:
		1:
			if multiplayer.is_server():
				load_random_level.rpc_id(1)
		2:
			if multiplayer.is_server():
				_change_to_playable_scene.rpc_id(1, "res://game/wait_lobby/wait_lobby.tscn")

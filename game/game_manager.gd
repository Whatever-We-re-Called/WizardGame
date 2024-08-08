class_name GameManager extends Node

@export var temp_level_pool: Array[PackedScene]

@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner
@onready var players_root: Node = %PlayersRoot
@onready var scene_spawner: MultiplayerSpawner = %SceneSpawner
@onready var active_scene: Node = %ActiveScene

var active_level: Level

const PLAYER_SCENE = preload("res://player/player.tscn")


func _ready() -> void:
	SessionManager.session_added.connect(_add_player)
	SessionManager.serverbound_client_disconnected.connect(_remove_player)
	SessionManager.server_closed.connect(_server_closed)
	
	for data in SessionManager.connected_clients.values():
		_add_player(data)


func _add_player(data):
	if multiplayer.is_server():
		var player = PLAYER_SCENE.instantiate()
		player.name = str(data.peer_id)
		player.peer_id = data.peer_id
		player.received_debug_input.connect(_handle_player_debug_input)
		players_root.add_child(player, true)
		
		if data.has("device_ids"):
			player.set_device(data.device_ids)
		
		teleport_player_to_random_spawn_point.rpc_id(1, data.peer_id)


func _remove_player(id):
	for child in players_root.get_children():
		if child.name == str(id):
			child.queue_free()


func _server_closed():
	for child in players_root.get_children():
		child.queue_free()


func get_players() -> Array[Player]:
	var result: Array[Player]
	
	for child in players_root.get_children():
		if child is Player:
			result.append(child as Player)
	
	return result


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
	
	print("A")
	_change_scene_to_level.rpc(chosen_level.resource_path)


@rpc("any_peer", "call_local")
func _change_scene_to_level(new_level_resource_path: String):
	print("B")
	print(new_level_resource_path)
	_clear_active_scene()
	var new_level_scene = load(new_level_resource_path).instantiate()
	new_level_scene.game_manager = self
	active_scene.add_child(new_level_scene)


func _clear_active_scene():
	for child in active_scene.get_children():
		child.queue_free()


@rpc("any_peer", "call_local")
func teleport_player_to_random_spawn_point(peer_id: int):
	var target_player = get_player_from_peer_id(peer_id)
	var spawn_location = get_tree().get_first_node_in_group("spawn_points").get_random_spawn_location()
	target_player.teleport.rpc_id(peer_id, spawn_location)
	print(target_player.name)
	


func _handle_player_debug_input(debug_value: int) -> void:
	match debug_value:
		1:
			load_random_level.rpc_id(1)

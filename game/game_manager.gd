extends Node

@export var temp_level_pool: Array[PackedScene]

@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner
@onready var players: Node = %Players
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
		player.received_debug_input.connect(_handle_player_debug_input)
		players.add_child(player, true)
		
		if data.has("device_ids"):
			player.set_device(data.device_ids)


func _remove_player(id):
	for child in players.get_children():
		if child.name == str(id):
			child.queue_free()


func _server_closed():
	for child in players.get_children():
		child.queue_free()


func load_random_level():
	randomize()
	var rng = RandomNumberGenerator.new()
	var chosen_level = temp_level_pool[rng.randi_range(0, temp_level_pool.size() - 1)]
	swap_active_scene_to(chosen_level)


func swap_active_scene_to(target_scene: PackedScene):
	for child in active_scene.get_children():
		print("!")
		child.queue_free()
	
	var new_scene = target_scene.instantiate()
	active_scene.add_child(new_scene)


func _handle_player_debug_input(debug_value: int) -> void:
	match debug_value:
		1:
			load_random_level()

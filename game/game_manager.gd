class_name GameManager extends Node

@export var game_settings: GameSettings

@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner
@onready var players_root: Node = %PlayersRoot
@onready var scene_spawner: MultiplayerSpawner = %SceneSpawner
@onready var active_scene_root: Node = %ActiveSceneRoot
@onready var map_progress_ui: CenterContainer = %MapProgressUI
@onready var game_states_node: Node = %GameStates
@onready var player_score_ui: CenterContainer = %PlayerScoreUI

var current_state: GameState
var game_states: Dictionary
var current_disaster_number: int = 1
var dead_players: Array[Player]
var scores: Dictionary

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
	set_multiplayer_authority(1)
	
	SessionManager.session_added.connect(_add_player)
	SessionManager.serverbound_client_disconnected.connect(_remove_player)
	SessionManager.server_closed.connect(_server_closed)
	
	# TODO Change this to load correct current game scene.
	change_to_scene("res://game/wait_lobby/wait_lobby.tscn")


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if current_state != null:
			current_state._update(delta)


func _add_player(data):
	if multiplayer.is_server():
		if players.size() == 0:
			_setup_server()
		
		var player = PLAYER_SCENE.instantiate()
		player.name = str(data.peer_id)
		player.peer_id = data.peer_id
		players_root.add_child(player, true)
		player.create_ability_nodes.rpc_id(data.peer_id)
		
		if data.has("device_ids"):
			player.set_device(data.device_ids)
		
		teleport_player_to_random_spawn_point.rpc_id(1, data.peer_id)
		_handle_add_player_signals.rpc()


func _setup_server():
	_setup_states()


func _setup_states():
	for child in game_states_node.get_children():
		if child is GameState:
			game_states[child.name.to_lower()] = child
			child.game_manager = self
	
	transition_to_state.rpc_id(1, "waiting", true, true)


@rpc("authority", "call_local", "reliable")
func _handle_add_player_signals():
	for player in players:
		player.killed.connect(_on_player_killed)
		player.received_debug_input.connect(_on_player_received_debug_input)


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


@rpc("authority", "call_local", "reliable")
func transition_to_state(new_state_name: String, skip_enter: bool = false, skip_exit: bool = false):
	var new_state = game_states.get(new_state_name.to_lower())
	if not new_state: return
	
	if current_state != null and skip_exit == false:
		print("exit")
		current_state._exit()
	
	if skip_enter == false:
		print("enter")
		new_state._enter()
	
	current_state = new_state


@rpc("authority", "call_local", "reliable")
func load_random_map():
	randomize()
	var rng = RandomNumberGenerator.new()
	var chosen_level = game_settings.map_pool[rng.randi_range(0, game_settings.map_pool.size() - 1)]
	
	change_to_scene.rpc_id(1, chosen_level.resource_path)


@rpc("authority", "call_local", "reliable")
func change_to_scene(new_scene_resource_path: String):
	_prepare_for_next_scene.rpc(new_scene_resource_path)
	
	var new_scene = load(new_scene_resource_path).instantiate()
	new_scene.game_manager = self
	active_scene_root.add_child(new_scene, true)
	
	new_scene.teleport_players_to_random_spawn_points.rpc_id(1)


@rpc("authority", "call_local", "reliable")
func _prepare_for_next_scene(new_scene_resource_path: String):
	scene_spawner.add_spawnable_scene(new_scene_resource_path)
	
	for child in active_scene_root.get_children():
		child.queue_free()


@rpc("authority", "call_local", "reliable")
func revive_dead_players():
	var respawn_points = active_scene.spawn_points.get_random_list_of_spawn_locations(players.size(), true)
	for i in range(dead_players.size()):
		var dead_player = dead_players[i]
		dead_player.teleport(respawn_points[i])
	await get_tree().process_frame
	for i in range(dead_players.size()):
		var dead_player = dead_players[i]
		dead_player.revive.rpc_id(dead_player.peer_id)
	dead_players.clear()


@rpc("authority", "call_local", "reliable")
func teleport_player_to_random_spawn_point(peer_id: int):
	var target_player = get_player_from_peer_id(peer_id)
	var spawn_location = active_scene.spawn_points.get_random_spawn_location()
	target_player.teleport(spawn_location)


func _on_player_killed(peer_id: int):
	_kill_player.rpc_id(1, peer_id)


@rpc("any_peer", "call_local", "reliable")
func _kill_player(peer_id: int):
	var killed_player = get_player_from_peer_id(peer_id)
	if not dead_players.has(killed_player):
		dead_players.append(killed_player)


@rpc("authority", "call_local", "reliable")
func increment_scores():
	for player in players:
		if not dead_players.has(player):
			if scores.has(player):
				scores[player] += 1
			else:
				scores[player] = 1


func _on_player_received_debug_input(debug_value: int) -> void:
	match debug_value:
		1:
			if multiplayer.is_server():
				transition_to_state.rpc_id(1, "gamestart")
		2:
			if multiplayer.is_server():
				transition_to_state.rpc_id(1, "waitlobby")

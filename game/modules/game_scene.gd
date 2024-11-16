extends GameManagerModule

@onready var scene_spawner: MultiplayerSpawner = %SceneSpawner
@onready var active_scene_root: Node = %ActiveSceneRoot
@onready var game_states_node: Node = %GameStates
@onready var map_progress_ui: CenterContainer = %MapProgressUI

var current_state_name: String
var current_state: GameState
var game_states: Dictionary
var current_map_disasters: Array[DisasterResource]
var current_disaster_number: int = 1
var dead_players: Array[Player]

var intermission: Intermission:
	get:
		for child in active_scene_root.get_children():
			if child is Intermission: return child
		return null


func _ready():
	super._ready()
	# TODO Change this to load correct current game scene.
	change_to_scene("res://wait_lobby/wait_lobby.tscn")


func _process(delta: float) -> void:
	if multiplayer.is_server():
		if current_state != null:
			current_state._update(delta)


func setup_states():
	for child in game_states_node.get_children():
		if child is GameState:
			game_states[child.name.to_lower()] = child
			child.game_scene = self
	
	transition_to_state.rpc_id(1, "waitlobby", true, true)


@rpc("authority", "call_local", "reliable")
func transition_to_state(new_state_name: String, skip_enter: bool = false, skip_exit: bool = false):
	var new_state = game_states.get(new_state_name.to_lower())
	if not new_state:
		push_error("Invalid state: ", new_state_name)
		return
	
	if current_state != null and skip_exit == false:
		current_state._exit()
	
	if skip_enter == false:
		new_state._enter()
	
	current_state = new_state
	var old_state_name = current_state_name
	current_state_name = new_state_name
	game_manager.on_game_state_change(old_state_name, new_state_name)


@rpc("authority", "call_local", "reliable")
func load_random_map():
	randomize()
	var rng = RandomNumberGenerator.new()
	var map_pool = game_manager.game_settings.map_pool
	var chosen_level = map_pool[rng.randi_range(0, map_pool.size() - 1)]
	
	change_to_scene.rpc_id(1, chosen_level.resource_path)


@rpc("authority", "call_local", "reliable")
func change_to_scene(new_scene_resource_path: String):
	_prepare_for_next_scene.rpc(new_scene_resource_path)
	
	var new_scene = load(new_scene_resource_path).instantiate()
	new_scene.game_manager = game_manager
	active_scene_root.add_child(new_scene, true)
	
	if new_scene is PlayableScene:
		new_scene.teleport_players_to_random_spawn_points.rpc_id(1)


@rpc("authority", "call_local", "reliable")
func _prepare_for_next_scene(new_scene_resource_path: String):
	scene_spawner.add_spawnable_scene(new_scene_resource_path)
	
	for child in active_scene_root.get_children():
		child.queue_free()


@rpc("authority", "call_local", "reliable")
func revive_dead_players():
	var respawn_points = game_manager.active_scene.spawn_points.get_random_list_of_spawn_locations(game_manager.players.size(), true)
	for i in range(dead_players.size()):
		var dead_player = dead_players[i]
		dead_player.teleport(respawn_points[i])
	await get_tree().process_frame
	for i in range(dead_players.size()):
		var dead_player = dead_players[i]
		dead_player.revive()
	dead_players.clear()


@rpc("authority", "call_local", "reliable")
func teleport_player_to_random_spawn_point(peer_id: int):
	var target_player = game_manager.get_player_from_peer_id(peer_id)
	var spawn_location = game_manager.active_scene.spawn_points.get_random_spawn_location()
	target_player.teleport(spawn_location)


func _on_player_killed(peer_id: int):
	_kill_player.rpc_id(1, peer_id)


@rpc("any_peer", "call_local", "reliable")
func _kill_player(peer_id: int):
	var killed_player = game_manager.get_player_from_peer_id(peer_id)
	if not dead_players.has(killed_player):
		dead_players.append(killed_player)

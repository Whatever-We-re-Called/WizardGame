class_name GameManager extends Node

@export var game_settings: GameSettings

@onready var game_ui: CanvasLayer = %GameUI
@onready var game_players: GameManagerModule = %GamePlayers
@onready var perks_manager: GameManagerModule = %PerksManager
@onready var game_scoring: GameManagerModule = %GameScoring
@onready var game_scene: GameManagerModule = %GameScene
@onready var pause_manager: GameManagerModule = %PauseManager

var map_number: int = 0

var players: Array[Player]:
	get:
		var result: Array[Player]
		for child in %GamePlayers.players_root.get_children():
			if child is Player: result.append(child)
		return result
var peer_id_players: Array[int]:
	get:
		var result: Array[int]
		for player in players:
			result.append(player.peer_id)
		return result
var active_scene: PlayableScene:
	get:
		for child in %GameScene.active_scene_root.get_children():
			if child is PlayableScene: return child
		return null


func _ready() -> void:
	set_multiplayer_authority(1, true)
	
	SessionManager.server_closed.connect(_on_server_closed)
	
	_setup_console_commands()


func is_host_or_local(data: Dictionary):
	return (data.peer_id == 1 and SessionManager.get_self_peer_id() == 1) or SessionManager.connection_strategy is LocalBasedConnection


func setup_server():
	game_scene.setup_states()


func _on_server_closed():
	SessionManager.disconnect_client()


func get_player_from_peer_id(peer_id: int) -> Player:
	for child in game_players.players_root.get_children():
		if child is Player and child.peer_id == peer_id:
			return child
	
	return null


func try_to_start_game():
	if multiplayer.is_server() and not game_ui.is_game_settings_ui_visible():
		game_scene.transition_to_state.rpc_id(1, "gamestart")


func return_to_wait_lobby():
	if multiplayer.is_server() and not game_ui.is_game_settings_ui_visible():
		game_scene.transition_to_state.rpc_id(1, "waitlobby")


func get_modules():
	var modules = []
	for child in get_children():
		if child is GameManagerModule:
			modules.append(child)
	return modules


func on_game_state_change(old_state: String, new_state: String):
	for module in get_modules():
		module.on_game_state_change(old_state, new_state)


func _on_player_received_debug_input(debug_value: int) -> void:
	match debug_value:
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass


func _setup_console_commands():
	CommandSystem.register("start", try_to_start_game)

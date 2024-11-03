class_name GameManager extends Node

@export var game_settings: GameSettings

@onready var game_ui: CanvasLayer = %GameUI
@onready var game_players: Node = %GamePlayers
@onready var game_scene: Node = %GameScene
@onready var pause_manager: Node = %PauseManager

var scores: Dictionary

var players: Array[Player]:
	get:
		var result: Array[Player]
		for child in %GamePlayers.players_root.get_children():
			if child is Player: result.append(child)
		return result
var active_scene: PlayableScene:
	get:
		for child in %GameScene.active_scene_root.get_children():
			if child is PlayableScene: return child
		return null


func _ready() -> void:
	set_multiplayer_authority(1, true)
	
	SessionManager.server_closed.connect(_on_server_closed)


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


func _open_online_invite(controller, player):
	player.controller.freeze_input = true
	var steam_menu = preload("res://multiplayer/steam/list/scenes/friend_list.tscn").instantiate()
	steam_menu.controller = controller
	steam_menu.closed.connect(func o(): player.controller.freeze_input = false)
	add_child(steam_menu)


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

class_name GameManagerModule extends Node

@onready var game_manager = get_parent() as GameManager


func _ready():
	SessionManager.session_added.connect(_non_handshake_connect)
	GameInstance.handshake_start_server.connect(_handshake_init)


func _handshake_init(handshake: HandshakeInstance):
	pass


func _non_handshake_connect(data):
	pass


func on_game_state_change(old_state, new_state):
	pass

extends GameManagerModule

@onready var players_root: Node = %PlayersRoot


func _ready():
	super._ready()
	SessionManager.serverbound_client_disconnected.connect(remove_player)


func _handshake_init(handshake: HandshakeInstance):
	handshake.handshake_complete.connect(add_player.bind(handshake.data))


func _non_handshake_connect(data):
	if game_manager.is_host_or_local(data):
		add_player(data)


func add_player(data: Dictionary):
	if multiplayer.is_server():
		if game_manager.players.size() == 0:
			game_manager.setup_server()
		
		var player = preload("res://player/player.tscn").instantiate()
		player.name = str(data.peer_id)
		player.peer_id = data.peer_id
		players_root.add_child(player, true)
		player.create_ability_nodes()
		
		if data.has("device_ids"):
			player.set_device(data.device_ids)
		
		game_manager.game_scene.teleport_player_to_random_spawn_point.rpc_id(1, data.peer_id)
		_handle_add_player_signals.rpc(data.peer_id)


@rpc("authority", "call_local", "reliable")
func _handle_add_player_signals(target_peer_id: int):
	var target_player = game_manager.get_player_from_peer_id(target_peer_id)
	target_player.killed.connect(game_manager.game_scene._on_player_killed)
	target_player.received_debug_input.connect(game_manager._on_player_received_debug_input)
	target_player.controller.paused.connect(game_manager.pause_manager.toggle_pause)


func remove_player(peer_id: int):
	if peer_id == 1 and SessionManager.get_self_peer_id() != 1:
		GameInstance.disconnected(true)
	for child in players_root.get_children():
		if child.peer_id == peer_id:
			child.queue_free()

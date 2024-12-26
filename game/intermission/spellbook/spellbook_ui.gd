extends IntermissionUI

signal finished
signal page_completed

var spellbook: Container
var handler: Variant


func setup_online():
	_create_ui_for_players(intermission.game_manager.players)
	_init_online_spellbook_handlers(intermission.game_manager.players)
	
	handler.init_all_ui_data()
	for player in intermission.game_manager.players:
		handler.start_sequence_for_player(player)


func setup_local():
	push_warning("Local play currently does not support the Intermission Spellbook state.")


func _create_ui_for_players(players: Array[Player]):
	for player in players:
		_create_ui_for_player.rpc_id(player.peer_id)


@rpc("authority", "call_local", "reliable")
func _create_ui_for_player():
	spellbook = preload("res://game/intermission/spellbook/spellbook_online.tscn").instantiate()
	add_child(spellbook)


func _init_online_spellbook_handlers(players: Array[Player]):
	for player in players:
		_init_online_spellbook_handler.rpc_id(player.peer_id)


@rpc("authority", "call_local", "reliable")
func _init_online_spellbook_handler():
	# Forced to an instantiable scene because RPC is so cool and funny
	# and awesome and cool to work with.
	handler = preload("res://game/intermission/spellbook/online/spellbook_handler_online.tscn").instantiate()
	add_child(handler, true)
	
	handler.spellbook_ui = self
	if multiplayer.is_server():
		handler.players = intermission.game_manager.players

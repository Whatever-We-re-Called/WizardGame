extends Node
class_name SpellsHandshake

signal client_complete


func _ready():
	GameInstance.handshake_init_client.connect(_start_client)
	GameInstance.handshake_start_server.connect(_start_server)
	
	
func _start_client(handshake: HandshakeInstance):
	handshake.register_promise(Promise.from(client_complete))
	
	
func _start_server(handshake: HandshakeInstance):
	var game_manager = GameInstance.current_scenes.get_child(0) as GameManager
	var players = game_manager.game_players.players_root.get_children()
	
	for player in players:
		if player.peer_id == handshake.peer_id:
			continue
			
		_set_player_spells.rpc_id(handshake.peer_id, player.peer_id, player.spell_inventory.equipped_spell_types)
		
	_complete.rpc_id(handshake.peer_id)


@rpc("any_peer", "reliable")
func _set_player_spells(peer_id, spell_types: Array[Spells.Type]):
	var game_manager = GameInstance.current_scenes.get_child(0) as GameManager
	var players = game_manager.game_players.players_root
	var player = players.get_node("./" + str(peer_id))
	
	for i in range(spell_types.size()):
		player.spell_inventory.set_spell_slot(i, spell_types[i])
		
	player.spell_inventory.sync.rpc_id(peer_id, SessionManager.get_self_peer_id())
	
	
@rpc("any_peer", "reliable")
func _complete():
	print("Spell HS complete")
	client_complete.emit()

extends Node
class_name AbilitiesHandshake

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
			
		_set_player_abilities.rpc_id(handshake.peer_id, player.peer_id, player.ability_types)
		
	_complete.rpc_id(handshake.peer_id)
			

@rpc("any_peer", "reliable")
func _set_player_abilities(peer_id, ability_types: Array[Abilities.Type]):
	var game_manager = GameInstance.current_scenes.get_child(0) as GameManager
	var players = game_manager.game_players.players_root
	
	for i in range(ability_types.size()):
		players.get_node("./" + str(peer_id))._set_ability_slot(i, ability_types[i])
		
	
@rpc("any_peer", "reliable")
func _complete():
	print("Ability HS complete")
	client_complete.emit()

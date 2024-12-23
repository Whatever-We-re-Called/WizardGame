extends Node


func _ready():
	SessionManager.session_added.connect(_client_connected)


func _client_connected(data):
	if SessionManager.get_self_peer_id() != 1:
		return
	var peer_id = data.peer_id
	if peer_id == 1:
		return
	if SessionManager.connection_strategy is LocalBasedConnection:
		return
		
	var handshake_node = HandshakeInstance.new()
	handshake_node.name = "HS_" + str(peer_id)
	handshake_node.peer_id = peer_id
	handshake_node.data = data
	
	var sync = HandshakeSync.new()
	sync.name = "Sync"
	handshake_node.add_child(sync)
	
	add_child(handshake_node)

	_connected_to_server_clientbound.rpc_id(peer_id)
	
	
@rpc("any_peer", "reliable")
func _connected_to_server_clientbound():
	var handshake_node = HandshakeInstance.new()
	handshake_node.name = "HS_" + str(SessionManager.get_self_peer_id())
	handshake_node.peer_id = SessionManager.get_self_peer_id()
	
	var sync = HandshakeSync.new()
	sync.name = "Sync"
	handshake_node.add_child(sync)
	
	add_child(handshake_node)

	GameInstance.handshake_init_client.emit(handshake_node)
	await get_tree().process_frame
	handshake_node._await_complete()
	handshake_node._start_handshake_serverbound()

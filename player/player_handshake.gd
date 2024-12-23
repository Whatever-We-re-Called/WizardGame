extends HandshakeExecutor
class_name PlayerHandshake
	
	
func _get_priority() -> int:
	return 10
	
	
func _run(peer_id: int):
	for player in SessionManager.connected_clients.values():
		_add_player.rpc_id(peer_id, player)
	_complete.rpc_id(peer_id)


@rpc("any_peer", "reliable")
func _add_player(data: Dictionary):
	if SessionManager.get_self_peer_id() != data.peer_id:
		var player = %GamePlayers._add_player_nodes(data)
		SessionManager.add_sync_filter(data.peer_id)
		player.sync._handle_sync.rpc_id(data.peer_id, SessionManager.get_self_peer_id(), true)

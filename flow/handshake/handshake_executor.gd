extends Node
class_name HandshakeExecutor

signal client_complete


func _ready():
	GameInstance.handshake_init_client.connect(_start_client)


func _get_priority() -> int:
	return 0


func _start_client(handshake: HandshakeInstance):
	print("[Client] ", self.name, " Handshake starting for ", handshake.peer_id)
	handshake.register_promise(_get_priority(), self, Promise.from(client_complete))
	
	
@rpc("any_peer", "reliable")
func _start_server(peer_id):
	print("[Server] ", self.name, " Handshake starting for ", peer_id)
	_run(peer_id)
	
	
func _run(peer_id):
	_complete.rpc_id(peer_id)
	
	
@rpc("any_peer", "reliable")
func _complete():
	print("[Client] ", self.name, " Handshake complete")
	client_complete.emit()

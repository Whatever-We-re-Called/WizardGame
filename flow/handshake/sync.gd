extends Node
class_name HandshakeSync

var peer_id

signal complete_signal

func _init(peer_id):
	self.peer_id = peer_id


func setup(handshake: HandshakeInstance):
	if handshake.peer_id == self.peer_id:
		handshake.register_promise(_start())


func _start() -> Promise:
	return Promise.from(complete_signal)
	
	
@rpc("any_peer", "reliable")
func complete():
	complete_signal.emit()

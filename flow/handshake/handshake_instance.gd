extends Node
class_name HandshakeInstance


var peer_id
var data
var _promises: Array[Promise] = []

signal handshake_complete

func register_promise(promise: Promise):
	_promises.append(promise)

	
@rpc("any_peer", "reliable")
func _start_handshake_serverbound():
	GameInstance.handshake_start_server.emit(self)


func _await_complete():
	if not _promises.is_empty():
		await Promise.all(_promises).wait()
	_end_handshake_serverbound.rpc_id(1)
	handshake_complete.emit()
	self.queue_free()
	
	
@rpc("any_peer", "reliable")
func _end_handshake_serverbound():
	handshake_complete.emit()
	self.queue_free()
		

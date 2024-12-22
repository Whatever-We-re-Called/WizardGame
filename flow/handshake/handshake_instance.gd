extends Node
class_name HandshakeInstance


var peer_id
var data
var _promises: Array[HandshakePromise] = []

signal handshake_complete

func register_promise(priority: int, node: Node, promise: Promise):
	_promises.append(HandshakePromise.new(priority, node, promise))


func _start_handshake_serverbound():
	_emit_start_signal.rpc_id(1)
	_promises.sort_custom(_promise_sorter)
	for promise in _promises:
		if promise.node:
			promise.node._start_server.rpc_id(1, peer_id)
	
@rpc("any_peer", "reliable")
func _emit_start_signal():
	GameInstance.handshake_start_server.emit(self)
	
	
func _promise_sorter(a: HandshakePromise, b: HandshakePromise) -> bool:
	return a.priority > b.priority


func _await_complete():
	print("[Client] Awaiting...")
	if not _promises.is_empty():
		await Promise.all(_get_promises()).wait()
		print("[Client] Done")
		_end_handshake_serverbound.rpc_id(1)
	handshake_complete.emit()
	print("[Client] Handshake Complete (", SessionManager.get_self_peer_id(), ")")
	self.queue_free()
	
	
func _get_promises() -> Array[Promise]:
	var promises: Array[Promise] = []
	for promise in _promises:
		promises.append(promise.promise)
	return promises
	
	
@rpc("any_peer", "reliable")
func _end_handshake_serverbound():
	print("[Server] Handshake complete (", SessionManager.get_self_peer_id(), ")")
	handshake_complete.emit()
	self.queue_free()
	
	
class HandshakePromise:
	var priority: int
	var node: Node
	var promise: Promise
	
	func _init(priority: int, node: Node, promise: Promise):
		self.priority = priority
		self.node = node
		self.promise = promise
		

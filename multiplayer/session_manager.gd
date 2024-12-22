extends Node

## Group of Signals that help standardize and clarify the mechanics of the default
## Godot multiplayer signals.
# Called on both client and server, but primarily clients to notify of a connections
signal serverbound_client_connected_to_server(id)
# Called on both client and server, notifying of a disconnect
signal serverbound_client_disconnected(id)
# Called only on server. Will be used to track player information on the server side
signal client_connected_to_server
# Called only on the client when they fail to connect. *This is not a packet based signal.*
signal client_connection_failed
# Called on clients and server when a session is successfully added with it's user data
signal session_added(user: Dictionary)
# Called only on the server when it's first opened
signal server_opened
# Called only on the server when the server is closed
signal server_closed

signal player_node_created(peer_id: int)


var connection_strategy: MultiplayerConnectionStrategy
var connected_clients = {}
var connected: bool = false
var sync_filter = []

var debug = false

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_serverbound_client_connected_to_server)
	multiplayer.peer_disconnected.connect(_serverbound_client_disconnected)
	multiplayer.connected_to_server.connect(_client_connected_to_server)
	multiplayer.connection_failed.connect(_client_connection_failed)
	
	multiplayer.allow_object_decoding = true


func _serverbound_client_connected_to_server(id):
	serverbound_client_connected_to_server.emit(id)
	
func _serverbound_client_disconnected(id):
	serverbound_client_disconnected.emit(id)
	remove_player(id)
	
func _client_connected_to_server():
	client_connected_to_server.emit()
	connected = true
	
func _client_connection_failed():
	client_connection_failed.emit()


func get_self_peer_id():
	return multiplayer.get_multiplayer_peer().get_unique_id()
	
	
func is_valid_peer(peer) -> bool:
	if peer is int:
		return multiplayer.get_peers().has(peer)
	else:
		if peer.name.is_valid_int():
			var peer_id = int(str(peer.name))
			return multiplayer.get_peers().has(int(peer_id)) or peer_id == 1
		else:
			return multiplayer.get_peers().has(peer.get_multiplayer_authority()) or peer.get_multiplayer_authority() == 1
		


func set_strategy(new_connection_strategy: MultiplayerConnectionStrategy):
	if self.connection_strategy != null:
		remove_child(self.connection_strategy)
		self.connection_strategy.free()
	self.connection_strategy = new_connection_strategy
	add_child(new_connection_strategy)
	
	
func create_server():
	connection_strategy.create_server()
	server_opened.emit()
	
	
func disconnect_client():
	connection_strategy.disconnect_from_server()
	connected = false
	connected_clients.clear()
	
	
func connect_to_server():
	connection_strategy.create_connection()
	
	
func close_server():
	var is_server = multiplayer.is_server()
	connection_strategy.close_server()
	connected = false
	if is_server:
		server_closed.emit()
	
	
func is_connected_to_peer():
	return connected
	
	
func add_player(user: Dictionary):
	_add_player.rpc_id(1, user)


func is_playing_local():
	return connection_strategy is LocalBasedConnection


@rpc("any_peer", "call_local", "reliable")
func _add_player(user: Dictionary):
	if SessionManager.debug:
		print("Adding player: ", user)
	connected_clients[user.peer_id] = user
	session_added.emit(user)
	for client in connected_clients.keys():
		_inform_of_others.rpc(connected_clients[client])


@rpc("any_peer", "call_local")
func _inform_of_others(user: Dictionary):
	if not connected_clients.has(user.peer_id):
		if SessionManager.debug:
			print(get_self_peer_id(), " Adding player: ", user)
		connected_clients[user.peer_id] = user
		session_added.emit(user)
	
	
func remove_player(peer_id):
	if SessionManager.debug:
		print(peer_id, " disconnected")
	connected_clients.erase(peer_id)
	
	
func add_sync_filter(peer_id):
	print("Adding sync filter ", peer_id, " for ", get_self_peer_id())
	sync_filter.append(peer_id)
	
	
func remove_sync_filter(peer_id):
	sync_filter.erase(peer_id)

extends Node

## Group of Signals that help standardize and clarify the mechanics of the default
## Godot multiplayer signals.
# Called on both client and server, but primarily clients to notify of a connections
signal clientbound_client_connected_to_server(id)
# Called on both client and server, notifying of a disconnect
signal clientbound_client_disconnected(id)
# Called only on server. Will be used to track player information on the server side
signal serverbound_client_connected_to_server
# Called only on the client when they fail to connect. *This is not a packet based signal.*
signal client_connection_failed


var connection_strategy: MultiplayerConnectionStrategy
var connected_clients = []

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_clientbound_client_connected_to_server)
	multiplayer.peer_disconnected.connect(_clientbound_client_disconnected)
	multiplayer.connected_to_server.connect(_serverbound_client_connected_to_server)
	multiplayer.connection_failed.connect(_client_connection_failed)


func _clientbound_client_connected_to_server(id):
	clientbound_client_connected_to_server.emit(id)
	connected_clients.append(id)
	
func _clientbound_client_disconnected(id):
	clientbound_client_disconnected.emit(id)
	connected_clients.erase(id)
	
func _serverbound_client_connected_to_server():
	serverbound_client_connected_to_server.emit()
	
func _client_connection_failed():
	client_connection_failed.emit()


func set_strategy(connection_strategy: MultiplayerConnectionStrategy):
	if self.connection_strategy != null:
		remove_child(self.connection_strategy)
		self.connection_strategy.free()
	self.connection_strategy = connection_strategy
	add_child(connection_strategy)
	
	
func create_server():
	connection_strategy.create_server()
	
	
func disconnect_client():
	connection_strategy.discconect_from_client()
	
	
func connect_to_server():
	connection_strategy.create_connection()
	
	
func close_server():
	connection_strategy.close_server()

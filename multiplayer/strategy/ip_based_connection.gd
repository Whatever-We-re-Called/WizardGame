extends MultiplayerConnectionStrategy
class_name IPBasedConnection

static var DEFAULT_PORT = 9002

var address
var port

var peer: ENetMultiplayerPeer


func _init(address = "127.0.0.1", port = DEFAULT_PORT):
	self.address = address
	self.port = port
	
	SessionManager.client_connected_to_server.connect(_on_connect)
	
	
func _on_connect():
	SessionManager.add_player({"name": null, "peer_id": peer.get_unique_id()})


func create_connection():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("There was an error while attempting to connect to ", address, ":", port)
		var message
		match error:
			20: message = "The port is already in use by another application."
			22: message = "You are already connected to or hosting a different server."
			_ : message = "An unknown error occurred."
		print(message)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	GameInstance.handshake_init_client.connect(func init(handshake: HandshakeInstance):
		handshake.handshake_complete.connect(func complete(data):
			SessionManager.add_player({"name": null, "peer_id": peer.get_unique_id()})
		)
	)
	
	
func create_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(self.port, 32)
	if error != OK:
		print("There was an error while attempting to create a server on port ", port)
		var message
		match error:
			20: message = "The port is already in use by another application."
			22: message = "You are already connected to or hosting a different server."
			_ : message = "An unknown error occurred."
		print(message)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	SessionManager.connected = true
	SessionManager.add_player({ "name": null, "peer_id": 1})
	if SessionManager.debug:
		print("Server online!")

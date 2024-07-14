extends MultiplayerConnectionStrategy
class_name IPBasedConnection

static var DEFAULT_PORT = 9002

var address
var port

var peer: ENetMultiplayerPeer


func _init(address = "127.0.0.1", port = DEFAULT_PORT):
	self.address = address
	self.port = port


func create_connection():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("There was an error while attempting to connect to ", address, ":", port)
		print(error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	
func create_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(self.port, 32)
	if error != OK:
		print("There was an error while attempting to create a server on port ", port)
		print(error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Server online!")

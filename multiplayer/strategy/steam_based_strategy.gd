extends MultiplayerConnectionStrategy
class_name SteamBasedStrategy


var lobby_id

var peer: SteamMultiplayerPeer


func _init(lobby_id = -1):
	self.lobby_id = lobby_id


func create_connection():
	if lobby_id == -1:
		print("Invalid Lobby ID")
		return
	peer = SteamMultiplayerPeer.new()
	var error = peer.connect_lobby(lobby_id)
	if error != OK:
		print("There was an error while connecting to a Steam lobby:")
		print(error)
		return
	
	multiplayer.set_multiplayer_peer(peer)
	

func disconnect_from_server():
	if peer != null:
		# Closes peer connection with server, will throw disconnect on other clients
		peer.disconnect_peer(1, true)
	
	
func create_server():
	peer = SteamMultiplayerPeer.new()
	var error = peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY)
	if error != OK:
		print("There was an error while creating a Staem lobby:")
		print(error)
		return
	
	peer.set_lobby_data("name", Steam.getPersonaName() + "'s Lobby")
	peer.set_lobby_joinable(true)
	
	multiplayer.set_multiplayer_peer(peer)

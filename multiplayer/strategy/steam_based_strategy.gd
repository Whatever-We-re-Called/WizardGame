extends MultiplayerConnectionStrategy
class_name SteamBasedStrategy


var lobby_id

var peer: SteamMultiplayerPeer


func _init(lobby_id = -1):
	self.lobby_id = lobby_id
	SessionManager.client_connected_to_server.connect(_on_connect)
	
	
func _on_connect():
	SessionManager.add_player({"steam_id": Steam.getSteamID(), "peer_id": peer.get_unique_id()})
	

func create_connection():
	if lobby_id == -1:
		print("Invalid Lobby ID")
		return
		
	Steam.lobby_joined.connect(_lobby_joined)
	Steam.joinLobby(lobby_id)
	
	
func _lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	if response != 1:
		print("There was an error while joining that lobby:")
		var fail_reason: String
		match response:
			2:  fail_reason = "That lobby no longer exists."
			3:  fail_reason = "You don't have permissions to join that lobby."
			4:  fail_reason = "That lobby is full."
			5:  fail_reason = "There was an unexpected error while joining that lobby."
			6:  fail_reason = "You are banned from that lobby."
			7:  fail_reason = "You cannot join that lobby due to having a limited account."
			8:  fail_reason = "That lobby is locked or disabled."
			9:  fail_reason = "That lobby is community locked."
			10: fail_reason = "A user in that lobby has blocked you from joining."
			11: fail_reason = "A user you have blocked is in that lobby."
		print(fail_reason)
		return
		
	peer = SteamMultiplayerPeer.new()
	var error = peer.create_client(Steam.getLobbyOwner(lobby_id), 0)
	if error != OK:
		print("There was an error while connecting to a Steam lobby:")
		var message
		match error:
			20: message = "The port is already in use by another application."
			22: message = "You are already connected to or hosting a different server."
			_ : message = "An unknown error occurred."
		print(message)
		return
	
	multiplayer.set_multiplayer_peer(peer)
	SessionManager.add_player({"steam_id": Steam.getSteamID(), "peer_id": peer.get_unique_id()})
	
	
func create_server():
	Steam.lobby_created.connect(_lobby_created)
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 32)
	
	
func _lobby_created(connect, lobby_id):
	if connect == 1:
		self.lobby_id = lobby_id
		
		Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s Lobby")
		Steam.setLobbyJoinable(lobby_id, true)
		
		peer = SteamMultiplayerPeer.new()
		var error = peer.create_host(0)
		if error != OK:
			print("There was an error while creating a Steam Lobby:")
			var message
			match error:
				20: message = "The port is already in use by another application."
				22: message = "You are already connected to or hosting a different server."
				_ : message = "An unknown error occurred."
			print(message)
			return
		
		multiplayer.set_multiplayer_peer(peer)
		SessionManager.connected = true
		SessionManager.add_player({"steam_id": Steam.getLobbyOwner(lobby_id), "peer_id": 1})
		if SessionManager.debug:
			print("Steam Lobby started: ", Steam.getLobbyData(lobby_id, "name"), " ({0})".format([lobby_id]))

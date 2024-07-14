extends Node
class_name MultiplayerConnectionStrategy


func create_connection():
	pass
	

func disconnect_from_server():
	if multiplayer.get_multiplayer_peer() != null and !multiplayer.is_server():
		# Closes peer connection with server, will throw disconnect on other clients
		multiplayer.get_multiplayer_peer().disconnect_peer(1, true)
	
	
func create_server():
	pass


func close_server():
	if multiplayer.get_multiplayer_peer() != null and multiplayer.is_server():
		multiplayer.get_multiplayer_peer().close()

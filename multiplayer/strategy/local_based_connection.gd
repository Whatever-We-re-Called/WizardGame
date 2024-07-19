extends MultiplayerConnectionStrategy
class_name LocalBasedConnection


var peer

func _init():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	

func disconnect_from_server():
	pass


func close_server():
	pass
	
	
func _input(event):
	if event is InputEventJoypadButton and not _is_known_device_id(event.device + 2):
		SessionManager.add_player({"peer_id": SessionManager.connected_clients.keys().size() + 1, "device_ids": [event.device + 2]})
		SessionManager.connected = true
	elif (event is InputEventMouseButton or event is InputEventKey) and not _is_known_device_id(event.device):
		SessionManager.add_player({"peer_id": SessionManager.connected_clients.keys().size() + 1, "device_ids": [event.device]})
		SessionManager.connected = true
	
	
func _is_known_device_id(id):
	return _get_client_from_device_id(id)
	
	
func _get_client_from_device_id(id):
	for client in SessionManager.connected_clients.values():
		if client.has("device_ids") and client.device_ids.has(id):
			return client
	return null
	
	
func _on_joy_connection_changed(device_id, connected):
	if not connected:
		var client = _get_client_from_device_id(device_id + 2)
		if client:
			SessionManager.remove_player(client.peer_id)

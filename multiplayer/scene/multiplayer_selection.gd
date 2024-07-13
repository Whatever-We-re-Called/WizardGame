extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	SessionManager.clientbound_client_connected_to_server.connect(on_connect)


func on_connect(id):
	print("Client connected: ", id)

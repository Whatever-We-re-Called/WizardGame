extends Control

@onready var buttons = [ $IP, $Steam, $Local ]
var selected_button = load("res://multiplayer/scene/selected_button_theme.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		button.pressed.connect(_update_button.bind(button))
	_update_button(null)
	SessionManager.clientbound_client_connected_to_server.connect(on_connect)
	
	
func _update_button(selected):
	if selected != null and selected.theme != null:
		return
	for button in buttons:
		button.theme = null
		for child in button.get_children():
			child.visible = false
	if selected:
		selected.theme = selected_button
		for child in selected.get_children():
			child.visible = true


func on_connect(id):
	print("Client connected: ", id)

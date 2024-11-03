extends Node


@export var current_scenes: Node

signal handshake_init_client(handshake)
signal handshake_start_server(handshake)

const available_scenes = { 
	"main_menu": preload("res://main_menu/main_menu.tscn"),
	"game_manager": preload("res://game/game_manager.tscn")
}
	
	
func swap_to_main_menu():
	_swap_to_scene("main_menu")
	
	
func host_online(create_peer_callback: Callable, wait = false):
	_swap_to_scene("game_manager")
	if wait:
		await get_tree().process_frame
	create_peer_callback.call()
	
	
func connect_online(create_peer_callback: Callable, wait = false):
	%MidFlowUI/Center/Text.text = "[center]Connecting..."
	%MidFlowUI.visible = true
	_kill_children()
	_swap_to_scene("game_manager")
	if wait:
		await get_tree().process_frame
	
	handshake_init_client.connect(_handshake_init)
	create_peer_callback.call()
		
		
func _handshake_init(handshake: HandshakeInstance):
	%MidFlowUI/Center/Text.text = "[center]Initializing..."
	
	handshake.handshake_complete.connect(func complete():
		%MidFlowUI.visible = false
	)
		
	
func connect_local():
	SessionManager.set_strategy(LocalBasedConnection.new())
	_swap_to_scene("game_manager")


func _swap_to_scene(scene: String):
	var children = current_scenes.get_children()
	var new_scene = available_scenes[scene].instantiate()
	current_scenes.add_child.call_deferred(new_scene)
	for child in children:
		current_scenes.remove_child.call_deferred(child)
		child.queue_free()
		
		
func _kill_children():
	for child in current_scenes.get_children():
		child.queue_free()
		
		
func disconnected(forced = false):
	if forced:
		%MidFlowUI/Center/Text.text = "[center]The server was closed"
		%MidFlowUI/Button.visible = true
		%MidFlowUI.visible = true
		
	swap_to_main_menu()
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface())


func _on_ui_button_pressed() -> void:
	%MidFlowUI/Button.visible = false
	%MidFlowUI.visible = false

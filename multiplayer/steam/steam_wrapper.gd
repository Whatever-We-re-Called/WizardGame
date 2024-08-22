extends Node

var init = true
var steam_impl


func _process(delta: float) -> void:
	if DisplayServer.get_name() == "headless": return
	if init:
		steam_impl = SteamImplementation.new()
		steam_impl.setup()
		init = false
	steam_impl.process()

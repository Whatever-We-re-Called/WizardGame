extends Node


var steam_impl

func _enter_tree():
	steam_impl = SteamImplementation.new()
	steam_impl.setup()
	
	
func _process(delta: float) -> void:
	steam_impl.process()

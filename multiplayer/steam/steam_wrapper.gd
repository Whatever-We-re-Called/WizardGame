extends Node


var steam_impl

func _enter_tree():
	steam_impl = SteamImplementation.new()
	
	
func _process(delta: float) -> void:
	steam_impl.process()

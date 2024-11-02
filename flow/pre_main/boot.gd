extends Node


func _ready():
	# TODO - logos
	# TODO - 'press to start'
	GameInstance.swap_to_main_menu()
	self.queue_free()

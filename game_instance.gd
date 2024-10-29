extends Node


func _ready() -> void:
	# TODO Add game logo and all that fun stuff.
	_load_main_menu()


func _load_main_menu():
	var main_menu = preload("res://main_menu/main_menu.tscn").instantiate()
	add_child(main_menu)

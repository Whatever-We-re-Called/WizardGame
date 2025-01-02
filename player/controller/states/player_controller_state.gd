class_name PlayerControllerState extends Node

var player: Player
var controller: PlayerController


func setup(player: Player):
	self.player = player
	self.controller = player.controller


func _enter():
	pass


func _exit():
	pass


func _handle_process(delta: float):
	pass


func _handle_pre_physics_process(delta: float):
	pass


func _handle_physics_process(delta: float):
	pass


func _handle_post_physics_process(delta: float):
	pass

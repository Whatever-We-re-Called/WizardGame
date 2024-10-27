extends Node


func on_enter():
	%Action.visible = true
	%Action/Invite.visible = false
	%Action/Join.visible = true
	
	%ControlType/Mouse.visible = false
	%ControlType/Controller.visible = true
	%ControlType.visible = true
	
	
func on_exit():
	%Action.visible = false
	%Action/Join.visible = false
	
	%ControlType.visible = false
	%ControlType/Mouse.visible = false
	%ControlType/Controller.visible = false


func on_player_update(player):
	pass

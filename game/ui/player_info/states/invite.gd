extends Node
class_name InviteState


var connected = false

func on_enter():
	%Action.visible = true
	%Action/Join.visible = false
	%Action/Invite.visible = true
	%InviteButton.visible = true
	
	var im = get_parent().get_parent().player.im
	im.device_swapped.connect(_on_device_switch)
	
	%ControlType/Mouse.visible = false
	%ControlType/Controller.visible = false
	
	%ControlType.visible = true
	match (im.get_device_type()):
		DeviceInputMap.DeviceType.KEYBOARD_MOUSE: %ControlType/Mouse.visible = true
		DeviceInputMap.DeviceType.CONTROLLER: %ControlType/Controller.visible = true
		
	
func on_exit():
	%Action.visible = false
	%Action/Invite.visible = false
	%InviteButton.visible = false
	
	%ControlType.visible = false
	%ControlType/Mouse.visible = false
	%ControlType/Controller.visible = false
	
	get_parent().get_parent().player.im.device_swapped.disconnect(_on_device_switch)


func on_player_update(player):
	if get_parent().get_parent().player != null and connected:
		get_parent().get_parent().player.im.device_swapped.disconnect(_on_device_switch)
	
	var im = player.im
	im.device_swapped.connect(_on_device_switch)
	connected = true
	
	_on_device_switch(-1, im.get_device_type())


func _on_device_switch(device_id, device_type):
	if device_type == DeviceInputMap.DeviceType.KEYBOARD_MOUSE:
		%ControlType/Controller.visible = false
		%ControlType/Mouse.visible = true
	else:
		%ControlType/Mouse.visible = false
		%ControlType/Controller.visible = true

extends Node
class_name LocalPlayerState


var connected = false


func on_enter():
	on_player_update(get_parent().get_parent().player)
	
	%Name.visible = true
	%InputType.visible = true
	
func on_exit():
	%Name.visible = false
	%InputType.visible = false
	%InputType/Keyboard.visible = false
	%InputType/Controller.visible = false
	
	
func on_player_update(player):
	%Name.text = "[center]Player " + str(player.peer_id)
	if get_parent().get_parent().player != null and connected:
		get_parent().get_parent().player.im.device_swapped.disconnect(on_device_swap)
	
	player.im.device_swapped.connect(on_device_swap)
	connected = true
	on_device_swap(-1, player.im.get_device_type())
	
	
func on_device_swap(device_id, device_type):
	print(device_type)
	if device_type == DeviceInputMap.DeviceType.KEYBOARD_MOUSE:
		%InputType/Controller.visible = false
		%InputType/Keyboard.visible = true
	else:
		%InputType/Keyboard.visible = false
		%InputType/Controller.visible = true

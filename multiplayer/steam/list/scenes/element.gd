extends Control

var friend
var expanded = false:
	set(value):
		if value:
			custom_minimum_size.y = 100
		else:
			custom_minimum_size.y = 64
		expanded = value


func set_friend(friend):
	self.friend = friend
	$HBoxContainer/VBoxContainer/Name.text = friend.display_name
	$HBoxContainer/VBoxContainer/Status.text = SteamFriend.SteamStatus.keys()[friend.status]
	
	var texture = ImageTexture.create_from_image(friend.icon)
	$HBoxContainer/Avatar.texture = texture


func _on_button_pressed() -> void:
	for element in get_parent().get_children():
		element.expanded = false
	
	expanded = !expanded
	


func _on_mouse_entered() -> void:
	$ColorRect.color = Color("#3591c5")


func _on_mouse_exited() -> void:
	$ColorRect.color = Color("#505050")


func _on_invite_pressed() -> void:
	print("Invite")

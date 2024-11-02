extends Control

var friend
var controller

func _ready():
	SessionManager.session_added.connect(_session_added)


func set_controller(controller):
	self.controller = controller
	%ControllerButton.visible = controller


func set_friend(friend):
	self.friend = friend
	$HBoxContainer/VBoxContainer/Name.text = truncate(friend.display_name)
	$HBoxContainer/VBoxContainer/Status.text = SteamFriend.SteamStatus.keys()[friend.status]
	
	var texture = ImageTexture.create_from_image(friend.icon)
	if texture != null:
		$HBoxContainer/Avatar.texture = texture
	
	for player in SessionManager.connected_clients.values():
		if player.has("steam_id"):
			if player.steam_id == friend.id:
				%InviteButton.set_in_game()


func truncate(string: String):
	if string.length() < 13:
		return string
	return string.left(10) + "..."


func _on_invite_pressed():
	%InviteButton.set_invited()
	if SteamWrapper.is_friend_playing_this_game(friend.id): # TODO - remove this once we're off 480
		SteamWrapper.invite(friend.id)
	
	
func _session_added(data):
	if data.has("steam_id") and data.steam_id == friend.id:
		%InviteButton.set_in_game()
		
		
func get_button():
	return %ControllerButton
	
	
func focus():
	%ControllerButton.grab_focus()


func _on_controller_button_focus_entered() -> void:
	$ColorRect.color = Color("#3591c5")


func _on_controller_button_focus_exited() -> void:
	$ColorRect.color = Color("#505050")

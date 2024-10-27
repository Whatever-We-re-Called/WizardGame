extends CanvasLayer


@export var expire_timer: Timer
@export var text: RichTextLabel
@export var icon: TextureButton

var current_lobby_id

func _ready():
	expire_timer.timeout.connect(_timeout)


func invite_received(friend_id, lobby_id):
	current_lobby_id = lobby_id
	
	var friend = SteamWrapper.get_friend_info(friend_id)
	text.text = "[center][b]" + friend.display_name + " has invited you to a game!"
	
	icon.texture_normal = ImageTexture.create_from_image(SteamWrapper.get_friend_avatar_large(friend_id))
	
	self.visible = true
	expire_timer.start()


func _accept():
	get_parent().swap_to_game_manager()
	await get_tree().process_frame
	SessionManager.set_strategy(SteamBasedStrategy.new(current_lobby_id))
	SessionManager.connect_to_server()
	get_parent()._remove_self()
	
	expire_timer.stop()
	
	
func _ignore():
	expire_timer.stop()


func _timeout():
	self.visible = false

extends CanvasLayer


@export var expire_timer: Timer
@export var text: RichTextLabel
@export var icon: TextureRect

var current_lobby_id

func _ready():
	expire_timer.timeout.connect(_timeout)


func invite_received(friend_id, lobby_id):
	current_lobby_id = lobby_id
	
	var friend = SteamWrapper.get_friend_info(friend_id)
	text.text = "[center][b]" + friend.display_name + " has invited you to a game!"
	
	icon.texture = ImageTexture.create_from_image(SteamWrapper.get_friend_avatar_large(friend_id))
	
	self.visible = true
	expire_timer.start()


func _accept():
	GameInstance.connect_online(func o():
		SessionManager.set_strategy(SteamBasedStrategy.new(current_lobby_id))
		SessionManager.connect_to_server()
	)
	
	expire_timer.stop()
	
	
func _ignore():
	expire_timer.stop()


func _timeout():
	self.visible = false

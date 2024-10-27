extends Node
class_name OnlinePlayerState


func on_enter():
	on_player_update(get_parent().get_parent().player)
	
	%Name.visible = true
	%Sprite.visible = true
	
	
func on_exit():
	%Name.visible = false
	%Sprite.visible = false
	
	
func on_player_update(player):
	var peer_info = SessionManager.connected_clients[player.peer_id]
	var friend = SteamWrapper.get_friend_info(peer_info.steam_id)
	
	%Name.text = "[center]" + friend.display_name
	%Sprite.texture = ImageTexture.create_from_image(SteamWrapper.get_friend_avatar_large(friend.id))

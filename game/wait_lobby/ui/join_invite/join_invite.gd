extends Control


var player


func set_player(peer_id):
	self.player = player
	
	if player.has("steam_id"):
		var friend = SteamWrapper.get_friend_info(player.steam_id)
		%Name.text = "[center]" + friend.display_name
		%PlayerSprite.texture = friend.icon
		
	
	

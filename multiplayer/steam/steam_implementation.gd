extends Node
class_name SteamImplementation


## Change this when we're on steam. Temporary testing ID
const app_id = 480

var current_friends_promise: Promise


func setup():
	OS.set_environment("SteamAppId", str(app_id))
	OS.set_environment("SteamGameId", str(app_id))
	Steam.steamInitEx()
	
	# This is what's called when a user accepts an invite or clicks join game
	Steam.join_requested.connect(_handle_join_game)
	# This is what's called when a user is invited to a game
	Steam.lobby_invite.connect(_handle_invite_game)
	print("Steam init")
	
func process():
	if Steam.isSteamRunning():
		Steam.run_callbacks()
	
	
func _handle_join_game(id, connect):
	if connect:
		SessionManager.set_strategy(SteamBasedStrategy.new(id))
		SessionManager.connect_to_server()
		
		
func _handle_invite_game(friend_id, lobby_id, game_id):
	if not is_friend_playing_this_game(friend_id):
		return
	
	var friend = get_friend(friend_id)
	SteamWrapper.invite_received.emit(friend, lobby_id)
		
		
func accept_invite(lobby_id):
	_handle_join_game(lobby_id, true)
		
		
func get_friends_list():
	return Steam.getUserSteamFriends()
	
	
func get_friend(id):
	return SteamFriend.new(id, Steam.getFriendPersonaName(id), SteamFriend.SteamStatus.In_Game)
	
	
func get_friend_icon_small(friend_id):
	var handle = Steam.getSmallFriendAvatar(friend_id)
	return get_image_from_steam_handle(handle)
	
	
func get_friend_avatar_medium(friend_id):
	var handle = Steam.getMediumFriendAvatar(friend_id)
	return get_image_from_steam_handle(handle)
	
	
func get_friend_avatar_large(friend_id):
	var handle = Steam.getLargeFriendAvatar(friend_id)
	return get_image_from_steam_handle(handle)
	
	
func get_image_from_steam_handle(handle):
	var image_size = Steam.getImageSize(handle)
	var buffer: PackedByteArray = Steam.getImageRGBA(handle).buffer
	
	var width = image_size.width
	var height = image_size.height
	
	return Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, buffer)


func invite(lobby_id, friend_id):
	Steam.inviteUserToLobby(lobby_id, friend_id)
	
	
func is_friend_playing_this_game(friend_id):
	var game = Steam.getFriendGamePlayed(friend_id)
	if game == null or not game.has("id"):
		return false
	return game.id == app_id

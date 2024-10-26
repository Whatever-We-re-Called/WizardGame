extends Node

var init = true
var steam_impl

var small_avatar_cache = {}
var medium_avatar_cache = {}
var large_avatar_cache = {}

signal invite_received(friend, lobby_id)


func _process(delta: float) -> void:
	if DisplayServer.get_name().contains("headless"): return
	if init:
		steam_impl = Node.new()
		steam_impl.script = load("res://multiplayer/steam/steam_implementation.gd")
		steam_impl.setup()
		init = false
	if steam_impl != null:
		steam_impl.process()
		

func is_steam_running() -> bool:
	return steam_impl != null
		
		
func get_friends_list():
	if not is_steam_running():
		return null
	var data = steam_impl.get_friends_list()
	var friends = []
	for friend in data:
		var status = -1 if is_friend_playing_this_game(friend.id) else friend.status
		friends.append(SteamFriend.new(friend.id, friend.name, status))
	return friends
	
	
func get_friend_info(id) -> SteamFriend:
	if not is_steam_running():
		return null
	return steam_impl.get_friend(id)
	
	
func get_friend_avatar_small(friend_id):
	if not is_steam_running():
		return null
		
	if small_avatar_cache.has(friend_id):
		return small_avatar_cache[friend_id]
	
	small_avatar_cache[friend_id] = steam_impl.get_friend_avatar_small(friend_id)
	return small_avatar_cache[friend_id]
	
	
func get_friend_avatar_medium(friend_id):
	if not is_steam_running():
		return null
		
	if medium_avatar_cache.has(friend_id):
		return medium_avatar_cache[friend_id]
	
	medium_avatar_cache[friend_id] = steam_impl.get_friend_avatar_medium(friend_id)
	return medium_avatar_cache[friend_id]
	
	
func get_friend_avatar_large(friend_id):
	if not is_steam_running():
		return null
		
	if large_avatar_cache.has(friend_id):
		return large_avatar_cache[friend_id]
	
	large_avatar_cache[friend_id] = steam_impl.get_friend_avatar_large(friend_id)
	return large_avatar_cache[friend_id]


func invite(friend_id):
	var strategy = SessionManager.connection_strategy
	if strategy is SteamBasedStrategy and strategy.lobby_id != -1:
		steam_impl.invite(strategy.lobby_id, friend_id)
		
		
func accept_invite(lobby_id):
	if not is_steam_running():
		return
	steam_impl.accept_invite(lobby_id)
		
		
func is_friend_playing_this_game(friend_id) -> bool:
	if not is_steam_running():
		return false
	return steam_impl.is_friend_playing_this_game(friend_id)

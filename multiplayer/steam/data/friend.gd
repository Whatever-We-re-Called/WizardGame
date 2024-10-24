extends Node
class_name SteamFriend


var id
var display_name
var status: SteamStatus
var icon: Image


func _init(id, display_name, status):
	self.id = id
	self.display_name = display_name
	self.status = status
	self.icon = SteamWrapper.get_friend_avatar_medium(id)


enum SteamStatus {
	Offline = 0,
	Online = 1,
	Busy = 2,
	Away = 3,
	Snooze = 4,
	Looking_To_Trade = 5,
	Looking_To_Play = 6,
	Max = 7, # Steam wth is this...
	In_Game = -1
}

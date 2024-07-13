extends Node


## Change this when we're on steam. Temporary testing ID
const app_id = 480


func _ready():
	OS.set_environment("SteamAppId", str(app_id))
	OS.set_environment("SteamGameId", str(app_id))
	Steam.steamInitEx()
	
	
func _process(_delta):
	Steam.run_callbacks()

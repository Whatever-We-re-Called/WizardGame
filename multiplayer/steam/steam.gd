extends Node


## Change this when we're on steam. Temporary testing ID
const app_id = 480


func _ready():
	OS.set_environment("SteamAppId", str(app_id))
	OS.set_environment("SteamGameId", str(app_id))
	Steam.steamInitEx()
	
	# This is what's called when a user accepts an invite or clicks join game
	Steam.join_requested.connect(_handle_join_game)
	
	
func _process(_delta):
	if Steam.isSteamRunning():
		Steam.run_callbacks()
	
	
func _handle_join_game(id, connect):
	if connect:
		SessionManager.set_strategy(SteamBasedStrategy.new(id))
		SessionManager.connect_to_server()
	
	

extends Control


var player
var current_state


func set_player(player):
	self.player = player
	

func set_state(state: State):
	if current_state != null:
		current_state.on_exit()
	match (state):
		State.Invite: current_state = $States/Invite
		State.Join: current_state = $States/Join
		State.OnlinePlayer: current_state = $States/OnlinePlayer
		State.LocalPlayer: current_state = $States/OnlinePlayer
	current_state.on_enter()
	
	
enum State {
	Invite,
	Join,
	OnlinePlayer,
	LocalPlayer
}

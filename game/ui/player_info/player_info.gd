extends Control
class_name PlayerInfoUI


var player
var current_state
var current_state_enum

signal invite_pressed(controller, player)


func set_player(player):
	if current_state != null:
		current_state.on_player_update(player)
	self.player = player
	

func set_state(state: State):
	if current_state != null:
		current_state.on_exit()
	match (state):
		State.Invite: current_state = $States/Invite
		State.Join: current_state = $States/Join
		State.OnlinePlayer: current_state = $States/OnlinePlayer
		State.LocalPlayer: current_state = $States/LocalPlayer
	current_state_enum = state
	current_state.on_enter()
	
	
enum State {
	Invite,
	Join,
	OnlinePlayer,
	LocalPlayer
}


func _on_button_pressed() -> void:
	if current_state_enum == State.Invite:
		invite_pressed.emit(false, player)
		

func _process(_delta):
	if player == null:
		return
	if current_state_enum != State.Invite:
		return
	if not Input.is_action_just_pressed(player.im.invite_friend):
		return
	invite_pressed.emit(true, player)

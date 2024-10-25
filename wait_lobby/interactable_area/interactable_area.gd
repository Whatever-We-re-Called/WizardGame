extends Area2D

signal interacted

@export var only_host_can_interact: bool = true
@export var interact_action_text: String = "Interact"

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var label: Label = $Label

var possible_interact_players: Array[Player]


func _ready() -> void:
	label.visible = false
	label.text = "Press Space to " + interact_action_text


func _process(delta: float) -> void:
	if label.visible == true:
		for player in possible_interact_players:
			if Input.is_action_just_pressed(player.im.jump):
				interacted.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_toggle_interact_player(body, true)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_toggle_interact_player(body, false)


func _toggle_interact_player(player: Player, toggled: bool):
	if only_host_can_interact and player.peer_id != 1: return
	
	player.controller.prevent_jump = toggled
	if toggled == true:
		possible_interact_players.append(player)
	elif toggled == false and possible_interact_players.has(player):
		possible_interact_players.erase(player)
	
	if SessionManager.is_valid_peer(self):
		_toggle_interact_player_rpc.rpc_id(player.peer_id, toggled)
	else:
		_toggle_interact_player_rpc(toggled)


@rpc("any_peer", "call_local", "reliable")
func _toggle_interact_player_rpc(toggled: bool):
	label.visible = toggled

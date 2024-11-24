class_name Intermission extends Node

enum State { START, SCORING, RESULTS, MODIFYING_LOCAL, MODIFYING_ONLINE, END }

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var start_ui: CenterContainer = %StartUI
@onready var scoring_ui: CenterContainer = %ScoringUI
@onready var results_ui: CenterContainer = %ResultsUI
@onready var modifying_local_ui: CenterContainer = %ModifyingLocalUI
@onready var modifying_online_ui: CenterContainer = %ModifyingOnlineUI
@onready var end_ui: CenterContainer = %EndUI

var game_manager: GameManager


func _ready():
	results_ui.continued.connect(
		func(): game_manager.game_scene.transition_to_state("waitlobby")
	)


@rpc("authority", "call_local", "reliable")
func set_state(state: State):
	start_ui.visible = (state == State.START)
	scoring_ui.visible = (state == State.SCORING)
	results_ui.visible = (state == State.RESULTS)
	modifying_local_ui.visible = (state == State.MODIFYING_LOCAL)
	modifying_online_ui.visible = (state == State.MODIFYING_ONLINE)
	end_ui.visible = (state == State.END)

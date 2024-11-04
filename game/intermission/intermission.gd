class_name Intermission extends Node

enum State { START, SCORING, RESULTS, PERKS, ABILITIES, END }

@onready var start_ui: CenterContainer = %StartUI
@onready var scoring_ui: CenterContainer = %ScoringUI
@onready var results_ui: CenterContainer = %ResultsUI
@onready var perks_ui: CenterContainer = %PerksUI
@onready var abilities_ui: CenterContainer = %AbilitiesUI
@onready var end_ui: CenterContainer = %EndUI

var game_manager: GameManager
var state: State = State.START


func set_state(state: State):
	self.state = state
	
	_update_ui_visibility()


func _update_ui_visibility():
	start_ui.visible = state == State.START
	scoring_ui.visible = state == State.SCORING
	results_ui.visible = state == State.RESULTS
	perks_ui.visible = state == State.PERKS
	abilities_ui.visible = state == State.ABILITIES
	end_ui.visible = state == State.END

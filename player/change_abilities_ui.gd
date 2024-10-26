extends CenterContainer

signal closed

@onready var ability_list: ItemList = %AbilityList
@onready var description_value_label: Label = %DescriptionValueLabel
@onready var slot_value_labels = [
	%Slot1ValueLabel,
	%Slot2ValueLabel,
	%Slot3ValueLabel
]
@onready var set_slot_buttons = [
	%SetSlot1Button,
	%SetSlot2Button,
	%SetSlot3Button
]


var player: Player


func _ready() -> void:
	for ability in Abilities.Type:
		ability_list.add_item(ability)
	
	description_value_label.text = "Nothing selected."
	ability_list.item_selected.connect(_on_item_selected)
	
	for i in range(set_slot_buttons.size()):
		var set_slot_button = set_slot_buttons[i]
		set_slot_button.pressed.connect(_on_set_slot.bind(i + 1))


func setup(player: Player):
	self.player = player
	_update_slot_value_labels(player.abilities)


func _update_slot_value_labels(abilities: Array[Abilities.Type]):
	for i in range(slot_value_labels.size()):
		var slot_value_label = slot_value_labels[i]
		slot_value_label.text = Abilities.Type.keys()[player.abilities[i]]


func _on_set_slot(slot: int):
	var player_abilities = player.abilities
	player_abilities[slot - 1] = _get_selected_ability()
	_update_slot_value_labels(player_abilities)
	_on_set_slot_rpc.rpc(player_abilities)


@rpc("any_peer", "call_local", "reliable")
func _on_set_slot_rpc(new_abilities: Array[Abilities.Type]):
	for i in range(new_abilities.size()):
		player.abilities[i] = new_abilities[i]
	
	print(player.abilities)
	player.clear_ability_nodes.rpc()
	player.create_ability_nodes()


func _get_selected_ability() -> Abilities.Type:
	if ability_list.get_selected_items().size() > 0:
		return ability_list.get_selected_items()[0]
	else:
		return Abilities.Type.NONE


func _on_item_selected(index: int):
	_update_description()


func _update_description():
	var selected_ability = _get_selected_ability()
	var description = Abilities.get_ability_resource(selected_ability).description
	description_value_label.text = description


func _on_save_and_close_button_pressed() -> void:
	closed.emit()

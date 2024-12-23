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
	visible = false
	
	for ability in Spells.Type:
		if ability != Spells.Type.keys()[Spells.Type.NONE]:
			ability_list.add_item(ability)
	
	description_value_label.text = "Nothing selected."
	ability_list.item_selected.connect(_on_item_selected)
	
	for i in range(set_slot_buttons.size()):
		var set_slot_button = set_slot_buttons[i]
		set_slot_button.pressed.connect(_on_set_slot.bind(i))


func setup(player: Player):
	self.player = player


func toggle():
	if visible == false:
		_update_slot_value_labels()
		ability_list.grab_focus()
		visible = true
		player.controller.freeze_input = true
	else:
		visible = false
		player.controller.freeze_input = false


func _update_slot_value_labels():
	for i in range(slot_value_labels.size()):
		slot_value_labels[i].text = player.spell_inventory.equipped_spells[i].resource.name


func _on_set_slot(slot: int):
	player.spell_inventory.set_spell_slot.rpc(slot, _get_selected_spell())
	_update_slot_value_labels()


func _get_selected_spell() -> Spells.Type:
	if ability_list.get_selected_items().size() > 0:
		return ability_list.get_selected_items()[0] + 1 # We skip NONE, so these are offset by 1
	else:
		return Spells.Type.NONE


func _on_item_selected(index: int):
	_update_description()


func _update_description():
	var selected_ability = _get_selected_spell()
	var description = Spells.get_spell_resource(selected_ability).description
	description_value_label.text = description


func _on_save_and_close_button_pressed() -> void:
	closed.emit()

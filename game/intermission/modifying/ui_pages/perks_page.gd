extends VBoxContainer

signal perk_chosen(perk_resource_path: String)

var perks: Array[Perk]


func setup(perks: Array[Perk]):
	self.perks = perks
	
	_update_buttons()


func _update_buttons():
	var perk_buttons = [ %PerkButton1, %PerkButton2, %PerkButton3 ]
	
	for i in range(perk_buttons.size()):
		var perk = perks[i]
		var perk_button = perk_buttons[i]
		
		perk_button.text = perk.name
		perk_button.icon = perk.icon
		(perk_button.get_child(0) as ColorRect).color = perk.get_color()
		
		perk_button.mouse_entered.connect(
			func(): %HighlightedPerkDescriptionLabel.text = perk.description
		)
		perk_button.mouse_exited.connect(
			func(): %HighlightedPerkDescriptionLabel.text = ""
		)
		perk_button.pressed.connect(
			func(): perk_chosen.emit(perk.resource_path)
		)

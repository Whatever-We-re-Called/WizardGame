extends SpellbookPage

signal perk_chosen(perk_resource_path: String)

var perks: Array[Perk]

const TYPE: Spellbook.PageType = Spellbook.PageType.PERK


func setup(perks: Array[Perk]):
	self.perks = perks
	
	_update_buttons()


func _update_buttons():
	var perk_buttons = [ %PerkButton1, %PerkButton2, %PerkButton3 ]
	var perk_description_labels = [ %PerkDescriptionLabel1, %PerkDescriptionLabel2, %PerkDescriptionLabel3 ]
	
	for i in range(perk_buttons.size()):
		var perk = perks[i]
		var perk_button = perk_buttons[i]
		var perk_description_label = perk_description_labels[i]
		
		perk_button.icon = perk.character.icon
		perk_description_label.text = "[center]%s[/center]" % [perk.description]
		(perk_button.get_child(0) as ColorRect).color = perk.get_color()
		
		perk_button.pressed.connect(
			func(): perk_chosen.emit(perk.resource_path)
		)

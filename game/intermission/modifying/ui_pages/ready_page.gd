class_name ReadyPage extends SpellbookPage

signal unreadied

const TYPE: Spellbook.PageType = Spellbook.PageType.READY

func _on_go_back_button_pressed() -> void:
	unreadied.emit()

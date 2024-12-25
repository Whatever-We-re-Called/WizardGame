extends SpellbookPage

signal unreadied

func _on_go_back_button_pressed() -> void:
	unreadied.emit()

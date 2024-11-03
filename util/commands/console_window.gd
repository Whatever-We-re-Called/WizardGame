extends Control


@export var text_input: TextEdit

func _ready():
	Console.window = self


func add_log(log_record):
	$ScrollContainer/VBoxContainer.add_child(log_record)
	
	while $ScrollContainer/VBoxContainer.get_child_count() > 50:
		$ScrollContainer/VBoxContainer.get_child(0).queue_free()
	
	await get_tree().process_frame
	$ScrollContainer.get_v_scroll_bar().value = $ScrollContainer.get_v_scroll_bar().max_value


func _process(_delta):
	if Input.is_key_pressed(KEY_ENTER):
		_submit()


func _submit() -> void:
	var text = text_input.text.replace("\n", "")
	if text != null and not text.is_empty():
		print(text)
		Console.log("> " + text)
		clear_text_edit()
		CommandSystem.execute(text)


func _on_text_edit_text_changed() -> void:
	text_input.text = text_input.text.replace("\n", "")
	text_input.set_caret_column(text_input.text.length())


func clear_text_edit():
	text_input.clear()

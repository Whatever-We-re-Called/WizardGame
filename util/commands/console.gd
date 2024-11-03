extends Node
class_name Console

static var logs = []
static var window: Control


static func log(string: String):
	_add_message(string)


static func error(string: String):
	_add_message("[color=indianred]" + string)
	

static func _add_message(string: String):
	logs.append(string)
	if window != null:
		print("Window not null")
		var log_record = preload("res://util/commands/log_record.tscn").instantiate()
		log_record.set_text(string)
		window.add_log(log_record)
		

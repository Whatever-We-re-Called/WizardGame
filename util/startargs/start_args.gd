extends Node

var arguments: Dictionary

func _ready():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		print(argument)
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		elif argument.find("--") > -1:
			arguments[argument.lstrip("--")] = true
	
	self.arguments = arguments
	
	
func get_value(key):
	if not arguments.has(key):
		return null
	return arguments[key]
	
	
func has(key: Variant):
	return arguments.has(key)

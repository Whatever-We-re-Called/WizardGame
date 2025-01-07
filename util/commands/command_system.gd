extends Node


var registry = {}


func _ready():
	var canvas = CanvasLayer.new()
	canvas.layer = 9999
	var console = preload("res://util/commands/console.tscn").instantiate()
	console.visible = false
	canvas.add_child(console)
	add_child(canvas)
	
	register("man <command>", man)
	
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("console_open") and Console.window != null:
		Console.window.visible = !Console.window.visible
		Console.window.clear_text_edit()


func register(command_with_args: String, callable: Callable, pass_null_args = false):
	var command = command_with_args.split(" ")[0]
	var data = { "usage": command_with_args, "callable": callable, "pass_null": pass_null_args }
	
	if command_with_args.length() > command.length():
		var args = command_with_args.substr(command.length() + 1)
		args = setup_args(args)
		if not args.is_empty():
			data["args"] = args
	
	var reg = []
	if registry.has(command):
		reg = registry[command]
	reg.append(data)
	
	registry[command] = reg
	
	
func setup_args(input: String) -> Array:
	var segments = input.split(" ")
	var parsed_segments = []
	
	for segment in segments:
		var required = false
		var arg_name = segment
		
		if segment.begins_with("<") and segment.ends_with(">"):
			required = true
			arg_name = segment.lstrip("<").rstrip(">")
		elif segment.begins_with("[") and segment.ends_with("]"):
			required = false
			arg_name = segment.lstrip("[").rstrip("]")
			
		parsed_segments.append({"name": arg_name, "required": required})
		
	return parsed_segments
	
	
func execute(input: String):
	var split_index = input.find(" ")
	var command = ""
	var args = ""
	if split_index == -1:
		command = input
	else:
		command = input.substr(0, split_index)
		args = input.substr(split_index + 1)
		
	if not registry.has(command):
		Console.error("The command '{0}' does not exist".format([command]))
		return
	
	args = parse_args(args)
	
	var handlers = 0
	
	for i in range(registry[command].size() - 1, -1, -1):
		var reg = registry[command][i]
		var expected_args = []
		if reg.has("args"):
			expected_args = reg.args
		var mapped_args = map_args_to_input(args, expected_args, reg.pass_null)
		
		if mapped_args is bool and not mapped_args:
			Console.error("Not enough args supplied")
			Console.error("Proper usage: " + reg.usage)
			return
			
		var node: Node = reg.callable.get_object()
		if not is_instance_valid(node):
			registry[command].remove_at(i)
			continue
		
		reg.callable.call(mapped_args)
		handlers += 1
		
	if handlers == 0:
		Console.log("There are currently no handlers for that command")
		
	
	
func map_args_to_input(input_array: Array, args_array: Array, pass_null: bool) -> Variant:
	var mapped_args = {}
	var input_index = 0
	var required_count = 0
	
	for arg in args_array:
		if arg.required:
			required_count += 1

	if input_array.size() < required_count:
		return false
	
	for i in range(args_array.size()):
		if input_index >= input_array.size():
			break
		
		var arg = args_array[i]
		var arg_name = arg.name
		var is_required = arg.required
		var required_mapped = 0

		if is_required:
			# Map required arguments
			mapped_args[arg_name] = input_array[input_index]
			input_index += 1
			required_mapped += 1
		else:
			# Only map optional arguments if there are enough remaining inputs
			var remaining_required = required_count - required_mapped
			var remaining_inputs = input_array.size() - input_index

			if remaining_inputs >= remaining_required:
				mapped_args[arg_name] = input_array[input_index]
				input_index += 1
	
	if pass_null:
		for arg in args_array:
			var arg_name = arg.name
			var is_required = arg.required
			
			if not is_required and not mapped_args.has(arg_name):
				mapped_args[arg_name] = null
	
	return mapped_args

	
	
func parse_args(input: String) -> Array:
	var results = []
	var regex = RegEx.new()
	regex.compile(r'"[^"]*"|\[[^\]]*\]|\S+')
	var matches = regex.search_all(input)
	
	for match in matches:
		var segment = match.get_string()
		
		if segment.begins_with('"') and segment.ends_with('"'):
			results.append(segment.lstrip("\"").rstrip("\""))
		
		elif segment.begins_with("[") and segment.ends_with("]"):
			var array_items = segment.lstrip("[").rstrip("]").split(",")
			results.append(array_items)
		
		else:
			if segment.is_valid_float():
				var float_value = float(segment)
				if float_value == int(float_value):
					results.append(int(float_value))
				else:
					results.append(float_value)
			else:
				results.append(segment)
	
	return results
	
	
func man(args):
	var command = args["command"]
	if not registry.has(command):
		Console.error("That is not a valid command")
		return
		
	Console.log("Valid usages:")
	for reg in registry[command]:
		Console.log(" - " + reg.usage)

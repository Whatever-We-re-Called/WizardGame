extends Node
class_name DeviceInputMap


var move_left = DefaultMappings.new([_keyboard(KEY_A)], [_axis(JOY_AXIS_LEFT_X, -1)])
var move_right = DefaultMappings.new([_keyboard(KEY_D)], [_axis(JOY_AXIS_LEFT_X, 1)])
var move_up = DefaultMappings.new([_keyboard(KEY_W)], [_axis(JOY_AXIS_LEFT_Y, -1)])
var move_down = DefaultMappings.new([_keyboard(KEY_S)], [_axis(JOY_AXIS_LEFT_Y, 1)])
var jump = DefaultMappings.new([_keyboard(KEY_SPACE)], [_controller(JOY_BUTTON_A)])


func _init(peer_id: int, device_ids: Array):
	for property in get_script().get_script_property_list():
		if property.name.ends_with(".gd"):
			continue
			
		var name = property.name
		var val = self[name]
			
		var action_name = name + "_" + str(peer_id)
		InputMap.add_action(action_name)
			
		for device in device_ids:
			var mode = "keyboard" if device == 0 else "controller"
			for input in val[mode]:
				if device > 0:
					input.device = device - 2
				
				InputMap.action_add_event(action_name, input)
				
		self[name] = action_name
	
	
func cleanup():
	for property in get_script().get_script_property_list():
		if property.name.ends_with(".gd"):
			continue
			
		InputMap.erase_action(self[property.name])
		
		
func _keyboard(key: Key):
	var input = InputEventKey.new()
	input.keycode = key
	return input
	
	
func _mouse_button(key: MouseButton):
	var input = InputEventMouseButton.new()
	input.button_index = key
	return input
	
	
func _mouse_motion():
	var input = InputEventMouseMotion.new()
	return input
	
	
func _controller(key: JoyButton):
	var input = InputEventJoypadButton.new()
	input.button_index = key
	return input
	
	
func _axis(axis: JoyAxis, value: float):
	var input = InputEventJoypadMotion.new()
	input.axis = axis
	input.axis_value = value
	return input
	

class DefaultMappings:
	var keyboard: Array
	var controller: Array
	
	func _init(keyboard: Array, controller: Array):
		self.keyboard = keyboard
		self.controller = controller

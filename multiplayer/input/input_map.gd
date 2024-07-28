extends Node
class_name DeviceInputMap

# Any variables that start with _ will be ignored by the processing.
# If it does not start with _, the system will attempt to add a keybind for it
var _player: Node
var _device_ids: Array
var _device_type: DeviceType


var move_left = DefaultMappings.new([_keyboard(KEY_A)], [_axis(JOY_AXIS_LEFT_X, -1)])
var move_right = DefaultMappings.new([_keyboard(KEY_D)], [_axis(JOY_AXIS_LEFT_X, 1)])
var move_up = DefaultMappings.new([_keyboard(KEY_W)], [_axis(JOY_AXIS_LEFT_Y, -1)])
var move_down = DefaultMappings.new([_keyboard(KEY_S)], [_axis(JOY_AXIS_LEFT_Y, 1)])
var jump = DefaultMappings.new([_keyboard(KEY_SPACE)], [_controller(JOY_BUTTON_A)])
var use_ability_1 = DefaultMappings.new([_mouse_button(MOUSE_BUTTON_LEFT)], [_controller(JOY_BUTTON_X)])
var use_ability_2 = DefaultMappings.new([_mouse_button(MOUSE_BUTTON_MIDDLE)], [_controller(JOY_BUTTON_Y)])
var use_ability_3 = DefaultMappings.new([_mouse_button(MOUSE_BUTTON_RIGHT)], [_controller(JOY_BUTTON_B)])
var debug_1 = DefaultMappings.new([_keyboard(KEY_1)], [_controller(JOY_BUTTON_DPAD_UP)])
var debug_2 = DefaultMappings.new([_keyboard(KEY_2)], [_controller(JOY_BUTTON_DPAD_RIGHT)])
var debug_3 = DefaultMappings.new([_keyboard(KEY_3)], [_controller(JOY_BUTTON_DPAD_DOWN)])
var debug_4 = DefaultMappings.new([_keyboard(KEY_4)], [_controller(JOY_BUTTON_DPAD_LEFT)])

func _init(player: Node, peer_id: int, device_ids: Array):
	for property in _get_property_list():
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
	
	self._player = player
	self._device_ids = device_ids
	
	self._player.add_child(self)
		
		
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		cleanup()
	
	
func cleanup():
	for property in _get_property_list():
		InputMap.erase_action(self[property.name])
		
	self._player.remove_child(self)
		
		
func _input(event):
	var owns_device = false
	for property in _get_property_list():
		if event.is_action(self[property.name]):
			owns_device = true
	if not owns_device:
		return
	
	if event is InputEventKey or event is InputEventMouse:
		_device_type = DeviceType.KEYBOARD_MOUSE
			
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_device_type = DeviceType.CONTROLLER
		
		
func get_device_type() -> DeviceType:
	return _device_type
		
		
func _get_property_list():
	var properties = []
	for property in get_script().get_script_property_list():
		if property.name.ends_with(".gd") or property.name.begins_with("_"):
			continue
		properties.append(property)
	return properties
		
		
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
		
		
enum DeviceType {
	KEYBOARD_MOUSE,
	CONTROLLER
}

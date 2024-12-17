extends Node
class_name DeviceInputMap

# Any variables that start with _ will be ignored by the processing.
# If it does not start with _, the system will attempt to add a keybind for it
var _player: Node
var _device_ids: Array
var _device_type: DeviceType

signal device_swapped(device_id, device_type)


var move_left = DefaultMappings.new([_keyboard(KEY_A)], [_axis(JOY_AXIS_LEFT_X, -0.3)])
var move_right = DefaultMappings.new([_keyboard(KEY_D)], [_axis(JOY_AXIS_LEFT_X, 0.3)])
var move_up = DefaultMappings.new([_keyboard(KEY_W)], [_axis(JOY_AXIS_LEFT_Y, -0.3)])
var move_down = DefaultMappings.new([_keyboard(KEY_S)], [_axis(JOY_AXIS_LEFT_Y, 0.3)])
var jump = DefaultMappings.new([_keyboard(KEY_SPACE)], [_controller(JOY_BUTTON_A)])
var use_spell_1 = DefaultMappings.new([_mouse_button(MOUSE_BUTTON_LEFT)], [_controller(JOY_BUTTON_X)])
var use_spell_2 = DefaultMappings.new([_mouse_button(MOUSE_BUTTON_MIDDLE)], [_controller(JOY_BUTTON_Y)])
var use_spell_3 = DefaultMappings.new([_mouse_button(MOUSE_BUTTON_RIGHT)], [_controller(JOY_BUTTON_B)])
var change_abilities = DefaultMappings.new([_keyboard(KEY_E)], [_controller(JOY_BUTTON_RIGHT_SHOULDER)])
var pause = DefaultMappings.new([_keyboard(KEY_ESCAPE)], [_controller(JOY_BUTTON_START)])
var invite_friend = DefaultMappings.new([], [_controller(JOY_BUTTON_DPAD_DOWN)])
var debug_1 = DefaultMappings.new([_keyboard(KEY_1)], [_controller(JOY_BUTTON_DPAD_UP)])
var debug_2 = DefaultMappings.new([_keyboard(KEY_2)], [_controller(JOY_BUTTON_DPAD_RIGHT)])
var debug_3 = DefaultMappings.new([_keyboard(KEY_3)], [_controller(JOY_BUTTON_DPAD_DOWN)])
var debug_4 = DefaultMappings.new([_keyboard(KEY_4)], [_controller(JOY_BUTTON_DPAD_LEFT)])
var debug_tab = DefaultMappings.new([_keyboard(KEY_TAB)], [_controller(JOY_BUTTON_LEFT_SHOULDER)])


func _init(player: Node, peer_id: int, device_ids: Array):
	for property in _get_property_list():
		var val = self[property.name]
			
		var action_name = property.name + "_" + str(peer_id)
		InputMap.add_action(action_name)
			
		for device in device_ids:
			var mode = "keyboard" if device == 0 else "controller"
			for input in val[mode]:
				if device > 0:
					input.device = device - 2
				
				InputMap.action_add_event(action_name, input)
				
		self[property.name] = action_name
	
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
	if event is InputEventKey or event is InputEventMouse:
		if event.device in _device_ids:
			owns_device = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if (event.device + 2) in _device_ids:
			owns_device = true
			
	if not owns_device:
		return
	
	if event is InputEventKey or event is InputEventMouse:
		if _device_type == null or _device_type == DeviceType.CONTROLLER:
			_device_type = DeviceType.KEYBOARD_MOUSE
			device_swapped.emit(event.device, DeviceType.KEYBOARD_MOUSE)
			
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion and event.axis_value < 0.5:
			return # Deadzone/Stick drift handling (it was aggresively emitting this signal)
		if _device_type == null or _device_type == DeviceType.KEYBOARD_MOUSE:
			_device_type = DeviceType.CONTROLLER
			device_swapped.emit(event.device + 2, DeviceType.CONTROLLER)
		
		
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

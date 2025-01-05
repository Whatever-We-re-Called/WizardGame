class_name TimerUtil

static func create_basic_timer(parent_node: Node, wait_time: float) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time
	parent_node.add_child(timer)
	
	return timer

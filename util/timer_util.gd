class_name TimerUtil

static func create_basic_timer(parent_node: Node, wait_time: float) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time
	parent_node.add_child(timer)
	
	return timer


static func create_basic_timer_with_timeout(parent_node: Node, wait_time: float, timeout_callable) -> Timer:
	var timer = create_basic_timer(parent_node, wait_time)
	timer.timeout.connect(timeout_callable)
	
	return timer

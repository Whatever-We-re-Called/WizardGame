class_name Daze extends Node

signal start
signal end

var daze_timer: Timer


func _ready():
	daze_timer = TimerUtil.create_basic_timer(self, 0)
	daze_timer.timeout.connect(func(): end.emit())


func add_daze(daze: int):
	if daze_timer.is_stopped():
		daze_timer.start(daze)
		start.emit()
	else:
		if daze > daze_timer.time_left:
			daze_timer.start(daze)


func is_dazed() -> bool:
	return not daze_timer.is_stopped()

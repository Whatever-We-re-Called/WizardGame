class_name Queue

var array: Array[Variant]


func enqueue(value: Variant):
	array.append(value)


func dequeue() -> Variant:
	if not is_empty():
		var result: Variant = array[0]
		array.remove_at(0)
		return result
	else:
		return null


func clear():
	array.clear()


func front() -> Variant:
	if not is_empty():
		return array[0]
	else:
		return null


func rear() -> Variant:
	if not is_empty():
		return array[array.size() - 1]
	else:
		return null


func size() -> int:
	return array.size()


func is_empty() -> bool:
	return array.size() == 0

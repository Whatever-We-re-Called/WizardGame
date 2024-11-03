extends Control

var controller = false
signal closed

func _ready() -> void:
	var friends = SteamWrapper.get_friends_list()
	friends = sort_friends_by_status_then_name(friends, [-1, 1, 3])
	
	for friend in friends:
		var element = preload("res://multiplayer/steam/list/scenes/element.tscn").instantiate()
		element.set_controller(controller)
		element.set_friend(friend)
		
		$VBoxContainer/Scroll/Container.add_child(element)
		
	await get_tree().process_frame
	if controller:
		var count = $VBoxContainer/Scroll/Container.get_children().size() - 1
		for i in count:
			set_neighbors(i, count, $VBoxContainer/Scroll/Container.get_child(i))
		
		if $VBoxContainer/Scroll/Container.get_child_count() > 0:
			$VBoxContainer/Scroll/Container.get_child(0).focus()
			
			%CloseButton.focus_neighbor_bottom = $VBoxContainer/Scroll/Container.get_child(0).get_path()
			%CloseButton.focus_next = $VBoxContainer/Scroll/Container.get_child(0).get_path()


func set_neighbors(i, max_neighbors, node):
	var children = $VBoxContainer/Scroll/Container.get_children()
	if i + 5 <= max_neighbors:
		node.get_button().focus_neighbor_bottom = children[i + 5].get_button().get_path()
	if i - 5 >= 0:
		node.get_button().focus_neighbor_top = children[i - 5].get_button().get_path()
	else:
		node.get_button().focus_neighbor_top = %CloseButton.get_path()
	if i + 1 <= max_neighbors:
		node.get_button().focus_neighbor_right = children[i + 1].get_button().get_path()
		node.get_button().focus_next = children[i + 1].get_button().get_path()
	if i - 1 >= 0:
		node.get_button().focus_neighbor_left = children[i - 1].get_button().get_path()
		node.get_button().focus_previous = children[i - 1].get_button().get_path()
	
	

func sort_friends_by_status_then_name(friends_array: Array, status_order: Array) -> Array:
	var grouped_friends = {}
	
	# Group friends by status
	for friend in friends_array:
		if not grouped_friends.has(friend.status):
			grouped_friends[friend.status] = []
		grouped_friends[friend.status].append(friend)
	
	# Sort each group alphabetically by display_name
	for status in grouped_friends.keys():
		grouped_friends[status].sort_custom(_sort_by_name)
	
	# Merge the sorted groups back into a single array in the order specified by status_order
	var sorted_friends = []
	for status in status_order:
		if grouped_friends.has(status):
			sorted_friends.append_array(grouped_friends[status])
	
	return sorted_friends

# Custom comparator for sorting by display_name alphabetically
func _sort_by_name(friend_a, friend_b) -> int:
	return friend_a.display_name.to_lower() < friend_b.display_name.to_lower()
	
	
func _process(_delta):
	$ColorRect.size = $VBoxContainer.size
	$ColorRect.position = $VBoxContainer.position
	
	
func _close():
	print("Close")
	closed.emit()
	self.queue_free()

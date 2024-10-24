extends Control


func _ready() -> void:
	var friends = SteamWrapper.get_friends_list()
	friends = sort_friends_by_status_then_name(friends, [-1, 1, 3])
	
	for friend in friends:
		var element = preload("res://multiplayer/steam/list/scenes/element.tscn").instantiate()
		element.set_friend(friend)
		
		$Scroll/Container.add_child(element)


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
		
		
func _process(delta):
	$ColorRect.position = $Scroll.position
	$ColorRect.size = $Scroll.size + Vector2(25, 25)

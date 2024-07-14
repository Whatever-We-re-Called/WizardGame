extends Button


func _ready():
	$Port.placeholder_text = str(IPBasedConnection.DEFAULT_PORT)


func _on_host_pressed():
	var port = $Port.text.strip_edges()
	if port == "" or port == null:
		port = IPBasedConnection.DEFAULT_PORT
	SessionManager.set_strategy(IPBasedConnection.new("127.0.0.1", int(port)))
	SessionManager.create_server()


func _on_join_pressed():
	var address = $Address.text.strip_edges()
	if address == "" or address == null:
		address = "127.0.0.1"
	var port = $Port.text.strip_edges()
	if port == "" or port == null:
		port = IPBasedConnection.DEFAULT_PORT
	print("Connecting to server {0}:{1}".format([address, port]))
	SessionManager.set_strategy(IPBasedConnection.new(address, int(port)))
	SessionManager.connect_to_server()

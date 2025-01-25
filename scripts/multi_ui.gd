extends Control

@export var address = "127.0.0.1" #LOCALHOST
@export var port = 18042
var peer

func _ready() -> void:
	multiplayer.peer_connected.connect(peerConnected)
	multiplayer.peer_disconnected.connect(peerDisonnected)
	multiplayer.connected_to_server.connect(connectedServer)
	multiplayer.connection_failed.connect(connectionFailed)


#called on server/client	
func peerConnected(id):
	print('Player has connected: ' + str(id))
	
func peerDisonnected(id):
	print('Player has disonnected: ' + str(id))
	if id == 1:
		# Host has left
		GameManager.players.clear()
		$LineEdit.editable = true
	else:
		GameManager.players.erase(id);
	getPlayerNames.rpc()
	
# called only client	
func connectedServer():
	print('Connected to Server')
	#sendPlayerInfo.rpc_id(1,$LineEdit.text,multiplayer.get_unique_id())
	sendPlayerInfo.rpc($LineEdit.text,multiplayer.get_unique_id())
	
func connectionFailed():
	print('Connection Fail')
	
	
func _on_host_button_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port,4)
	
	if error != OK:
		print('Error Could not Host')
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	sendPlayerInfo($LineEdit.text,1)
	$LineEdit.editable = false
	$PanelContainer/HBoxContainer/StartButton.disabled = false
	print('Waiting for players')
	
@rpc('any_peer')
func sendPlayerInfo(name, id):
	# Check if player does not already exist
	if not GameManager.players.has(id):
		GameManager.players[id] = {
			'name': name,
			'id': id,
			'score': 0
		 }
	# If the server, broadcast the player info
	#if multiplayer.is_server():
	for player_id in GameManager.players:
		sendPlayerInfo.rpc(GameManager.players[player_id].name, player_id)
		getPlayerNames.rpc()

@rpc("any_peer","call_local")
func getPlayerNames():
	if $Players/VBoxContainer:
		var node = $Players/VBoxContainer
		for n in node.get_children():
			node.remove_child(n)
			n.queue_free()
		for player_id in GameManager.players:
			var label = Label.new()
		##label.name = player_id
			label.text = GameManager.players[player_id].name
			node.add_child(label)

func _on_join_button_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)	
	$LineEdit.editable = false


func _on_start_button_button_down() -> void:
	# Only have host start
	if multiplayer.get_unique_id() != 1:
		return
	startGame.rpc()
	pass # Replace with function body.
	
@rpc("call_local","any_peer")
func startGame():
	var scene = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	sendPlayerInfo($LineEdit.text,multiplayer.get_unique_id())
	print('START')

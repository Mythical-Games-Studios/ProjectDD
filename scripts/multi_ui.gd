extends Control

# export address, peer
@export var address = "127.0.0.1"
@export var port = 18042
var peer

# ready function
func _ready() -> void:
	multiplayer.peer_connected.connect(peerConnected)
	multiplayer.peer_disconnected.connect(peerDisonnected)
	multiplayer.connected_to_server.connect(connectedServer)
	multiplayer.connection_failed.connect(connectionFailed)


# peer Connected (runs on clients/server)
func peerConnected(id):
	# print('Player has connected: ' + str(id))
	pass
	
# peer Disconnected (runs on clients/server)	
func peerDisonnected(id):
	# print('Player has disonnected: ' + str(id))
	
	# if players in game then kick them out
	if GameManager.ingame:
		GameManager.returnhome()
	
	# if host has left
	if id == 1:
		
		# reset buttons and players
		GameManager.players.clear()
		%PlayerNameLabel.editable = true
		ipedit('',true)
		changebuttonsstate(true)
	else:
		
		# only remove the player
		GameManager.players.erase(id);
		
	# change player count	
	getPlayerNames()
	
# connected Server (client)
func connectedServer():
	#print('Connected to Server')
	
	# Disable UI
	send_playerinfo_toserver.rpc(%PlayerNameLabel.text,multiplayer.get_unique_id())
	changebuttonsstate(false)
	statushandle('Connection Success!')
	
# connection Failed (client)
func connectionFailed():
	print('Connection Fail')
	changebuttonsstate(true)
	statushandle('Connection Failed!')
	
# host button pressed	
func _on_host_button_button_down() -> void:
	
	# get local ip
	var ip = get_local_ip()
	ipedit(ip,false)
	
	# create new peer
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port,4)
	
	# check for errors
	if error != OK:
		print('Error Could not Host')
		statushandle('Hosting Error: Could not Host!')
		return
	
	# set peer and compression
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	# send player info
	send_playerinfo_toserver(%PlayerNameLabel.text,1)
	
	# prevent UI
	%PlayerNameLabel.editable = false
	#%StartButton.disabled = false
	
	# change states
	getPlayerNames()
	#print('Waiting for players')
	statushandle('Hosting Success!')
	changebuttonsstate(false)
	
# send player info
#### REMEMBER
## Server → Client: @rpc("authority", "call_remote", "reliable")
## Server → Every peer: @rpc("authority", "call_local", "reliable")
## Client → Server: @rpc("any_peer", "call_remote", "reliable")
## Authority Client → Server: @rpc("authority", "call_remote", "reliable") set_multiplayer_authority(peer_id)

# send player info to from client to server
@rpc("any_peer", "call_remote", "reliable")
func send_playerinfo_toserver(player_name, player_mid):

	# check if player does not already exist
	if not GameManager.players.has(player_mid):
		GameManager.players[player_mid] = {
			'name': player_name,
			'id': player_mid,
			'score': 0
		 }
	
	# broadcast the player info to clients
	for player_id in GameManager.players:
		
		# prevent server
		if player_id == 1: continue
		
		# send player info to other clients
		send_playerinfo_toclient.rpc_id(player_id,GameManager.players)
	
	# get the player names for UI
	getPlayerNames()
		
# send player info to from server to clients
@rpc("any_peer", "call_remote", "reliable")
func send_playerinfo_toclient(server_players):

	for player_id in server_players:
		# check if player does not already exist
		if not GameManager.players.has(player_id):
			GameManager.players[player_id] = {
				'name': server_players[player_id].name,
				'id': player_id,
				'score': 0
		 	}
	
	# get the player names for UI
	getPlayerNames()
# function get player names on UI
func getPlayerNames():
	# get container
	var players_container = %PlayersPanel.get_child(0)
	
	# loop through text if player has left
	for label in players_container.get_children():
		if GameManager.players.get(str(label.name)): continue
		players_container.remove_child(label)
		label.queue_free()
	
	# loop through players
	for player_id in GameManager.players:
		var player_name = GameManager.players[player_id].name
		
		# check if text is there, skip
		var exists = players_container.get_node_or_null(player_name+'_ID')
		if exists: continue
		
		# create label
		var label = Label.new()
		label.name = str(player_id) + '_ID'
		label.text = player_name
		players_container.add_child(label)
		
	# change player count
	changePlayerCount()

func _on_join_button_button_down() -> void:
	var address = $IPLabel.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	ipedit(address,false)
	multiplayer.set_multiplayer_peer(peer)	
	%PlayerNameLabel.editable = false


func _on_start_button_button_down() -> void:
	# Only have host start
	if multiplayer.get_unique_id() != 1:
		return
	if len(GameManager.players) < 2:
		statushandle('Error: Can not start with 1 player')
		return
	startGame.rpc()
	pass # Replace with function body.
	
@rpc("call_local","authority")
func startGame():
	var scene = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	print('START')
	GameManager.world = scene
	GameManager.mui = self
	GameManager.ingame = true
	GameManager.game_cycle()
	
# set player count in the UI	
func changePlayerCount():
	var c = len(GameManager.players)
	%PlayerCountLabel.text = 'Player Count (' + str(c) + '/4)'
	
	
@rpc("call_local",'any_peer')
func sendUpdate(message):
	pass #TODO

func changebuttonsstate(state):
	state = not state
	%HostButton.disabled = state
	%JoinButton.disabled = state
	
func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text:
		changebuttonsstate(true)
	else:
		changebuttonsstate(false)
		
func animatestatus():
	var tween = get_tree().create_tween()
	tween.tween_property($StatusLabel, "position", Vector2($StatusLabel.position.x, 50), 0.5)
	await get_tree().create_timer(1.0).timeout
	tween = get_tree().create_tween()
	tween.tween_property($StatusLabel, "position", Vector2($StatusLabel.position.x, -50), 0.5)

func statushandle(text):
	$StatusLabel.text = text
	animatestatus()



func get_local_ip():
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "127.0.0.1" # Fallback if no local IP is found
	
	
func ipedit(value,state):
	$IPLabel.text = value
	$IPLabel.editable = state

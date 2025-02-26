extends Control

# export address, peer
@export var address = "127.0.0.1"
@export var port = 18042

var udp := PacketPeerUDP.new()
var udp_address = '255.255.255.255'
var udp_port = 23404
var peer

var lobbies = {}

# ready function
func _ready() -> void:
	multiplayer.peer_connected.connect(peerConnected)
	multiplayer.peer_disconnected.connect(peerDisonnected)
	multiplayer.connected_to_server.connect(connectedServer)
	multiplayer.connection_failed.connect(connectionFailed)
	listen_udp()

# peer Connected (runs on clients/server)
func peerConnected(id):
	print('Player has connected: ' + str(id))
	pass
	
# peer Disconnected (runs on clients/server)	
func peerDisonnected(id):
	print('Player has disonnected: ' + str(id))
	
	# if players in game then kick them out
	if GameManager.ingame:
		GameManager.returnhome()
	
	# if host has left
	if id == 1:
		
		# reset buttons and players
		GameManager.players.clear()
		%PlayerNameLabel.editable = true
		changebuttonsstate(true)
	else:
		
		# only remove the player
		GameManager.players.erase(id);
		
	# change player count	
	#getPlayerNames()
	
# connected Server (client)
func connectedServer():
	print('Connected to Server')
	
	# Disable UI
	send_playerinfo_toserver.rpc(%PlayerNameLabel.text,multiplayer.get_unique_id())
	changebuttonsstate(false)
	
# connection Failed (client)
func connectionFailed():
	print('Connection Fail')
	changebuttonsstate(true)
	
# host button pressed	
func _on_host_button_button_down() -> void:
	
	
	# create new peer
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port,4)
	
	# check for errors
	if error != OK:
		print('Error Could not Host')
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
	#getPlayerNames()
	print('Host Success! Waiting for players')
	changebuttonsstate(false)
	
	# udp broadcast
	udp.set_broadcast_enabled(true)
	udp.set_dest_address(udp_address, udp_port)
	broadcast_udp()
	
	# send player to lobby ui
	send_to_lobby()
	
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
	#getPlayerNames()
		
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
	#getPlayerNames()
	
# function get player names on UI
#func getPlayerNames():
	## get container
	#var players_container = %PlayersPanel.get_child(0)
	#
	## loop through text if player has left
	#for label in players_container.get_children():
		#if GameManager.players.get(str(label.name)): continue
		#players_container.remove_child(label)
		#label.queue_free()
	#
	## loop through players
	#for player_id in GameManager.players:
		#var player_name = GameManager.players[player_id].name
		#
		## check if text is there, skip
		#var exists = players_container.get_node_or_null(player_name+'_ID')
		#if exists: continue
		#
		## create label
		#var label = Label.new()
		#label.name = str(player_id) + '_ID'
		#label.text = player_name
		#players_container.add_child(label)
		
	# change player count
	# changePlayerCount()


# start button pressed
#func _on_start_button_button_down() -> void:
	#
	## Only have host start
	#if multiplayer.get_unique_id() != 1:
		#return
		#
	## Check if there are two or more players	
	#if len(GameManager.players) < 2:
		#statushandle('Error: Can not start with 1 player')
		#return
		#
	## rpc call to start the game	
	#startGame.rpc()

# rpc to start game	
#@rpc("authority", "call_local", "reliable")
#func startGame():
	#
	## load world
	#var scene = load("res://game/main.tscn").instantiate()
	#get_tree().root.add_child(scene)
	#
	## hide this ui
	#self.hide()
	#
	##print('START')
	#
	## set gamemanager variables
	#GameManager.world = scene
	#GameManager.mui = self
	#GameManager.ingame = true
	#
	## start game cycle
	#GameManager.game_cycle()
	
# set player count in the UI	
#func changePlayerCount():
	#
	## get len players then set it to the UI
	#var c = len(GameManager.players)
	#%PlayerCountLabel.text = 'Player Count (' + str(c) + '/4)'
	
# change button states function	
func changebuttonsstate(state):
	
	# reverse the state and set disabled
	state = not state
	%HostButton.disabled = state


# line edit function	
func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text:
		changebuttonsstate(true)
	else:
		changebuttonsstate(false)

# animation for status		
#func animatestatus():
	#var tween = get_tree().create_tween()
	#tween.tween_property($StatusLabel, "position", Vector2($StatusLabel.position.x, 50), 0.5)
	#await get_tree().create_timer(1.0).timeout
	#tween = get_tree().create_tween()
	#tween.tween_property($StatusLabel, "position", Vector2($StatusLabel.position.x, -50), 0.5)

# status handle function
#func statushandle(text):
	#$StatusLabel.text = text
	#animatestatus()


# get local ip
func get_local_ip():
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "127.0.0.1" # Fallback if no local IP is found
	
# function udp broadcast
func broadcast_udp():
	while true:
		var local_ip = get_local_ip()
		var message = str(len(GameManager.players)) + '|' + local_ip + '|' + str(port) + '|' + GameManager.players[1].name
		udp.put_packet(message.to_utf8_buffer())
		await get_tree().create_timer(1.0).timeout

var udp2 = PacketPeerUDP.new()

func listen_udp():
	#udp.bind(udp_port,'0.0.0.0')
	#print("Listening for game lobbies...")
	if udp2.bind(udp_port) != OK:
		print("❌ Failed to bind UDP listener on port", udp_port)
		return
	print("✅ Listening for UDP packets on port", udp_port)

func _process(_delta):
	if udp2.get_available_packet_count() > 0:
		var packet = udp2.get_packet().get_string_from_utf8()
		var lobby = udp_packet_to_lobby(packet)
		if not lobbies.get(lobby.ip):
			lobbies[lobby.ip] = lobby
			add_lobby_ui(lobby)

func add_lobby_ui(lobby):
	var button = Button.new()
	button.text = lobby.host + ' (' + str(lobby.players) + '/4)'
	button.name = lobby.ip
	%LobbyListContainer.add_child(button)
	button.button_down.connect(func(): join_lobby(lobby.ip, lobby.port))

func join_lobby(ip,port):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, int(port))
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)	
	stop_listen_udp()
	send_to_lobby()

func remove_lobby_ui(lobby):
	pass

func udp_packet_to_lobby(packet):
	
	# #p|ip|pt|pn

	var packet_split = packet.split('|')
	var player_count = packet_split[0]
	var ip = packet_split[1]
	var port = packet_split[2]
	var player_name = packet_split[3]
	
	var lobby = {
		'host': player_name,
		'ip': ip,
		'port': port,
		'players': player_count,
		'timestamp': Time.get_ticks_msec()
	}
	
	return lobby
		
func stop_listen_udp():
	udp.close()
	
func send_to_lobby():
	var lobby = preload("res://ui/local_lobby_ui.tscn").instantiate()
	get_tree().root.add_child(lobby)
	hide()

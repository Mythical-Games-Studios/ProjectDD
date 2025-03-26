extends Control

# export address, peer
@export var address = "127.0.0.1"
@export var port = 16384

var udp_broadcast := PacketPeerUDP.new() # For sending broadcasts
var udp_listener := PacketPeerUDP.new()  # For listening to broadcasts
var udp_address = "255.255.255.255"
var udp_port = 23404
var peer
var lobbies = {}

# ready function
func _ready() -> void:
	multiplayer.peer_connected.connect(peerConnected)
	multiplayer.peer_disconnected.connect(peerDisonnected)
	multiplayer.connected_to_server.connect(connectedServer)
	multiplayer.connection_failed.connect(connectionFailed)
	multiplayer.server_disconnected.connect(disconnectedServer)
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
	#stop_listen_udp()

# disconnected Server (client)
func disconnectedServer():
	GameManager.players.clear()
	#listen_udp()
	changebuttonsstate(true)
	show()
	
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
	#%PlayerNameLabel.editable = false
	#%StartButton.disabled = false
	
	# change states
	#getPlayerNames()
	print('Host Success! Waiting for players')
	print(OS.get_environment("COMPUTERNAME"), " is hosting on ", IP.get_local_addresses())
	changebuttonsstate(false)
	
	# udp broadcast
	broadcast_udp()
	stop_listen_udp()
	
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
	
	
# change button states function	
func changebuttonsstate(state):
	
	# reverse the state and set disabled
	state = not state
	%HostButton.disabled = state
	for x in %LobbyListContainer.get_children():
		x.disabled = state


# line edit function	
func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text:
		changebuttonsstate(true)
	else:
		changebuttonsstate(false)

# animation for status		
func animatestatus():
	var tween = get_tree().create_tween()
	tween.tween_property($StatusLabel, "position", Vector2($StatusLabel.position.x, 50), 0.5)
	await get_tree().create_timer(1.0).timeout
	tween = get_tree().create_tween()
	tween.tween_property($StatusLabel, "position", Vector2($StatusLabel.position.x, -50), 0.5)

# status handle function
func statushandle(text):
	$StatusLabel.text = text
	animatestatus()


# get local ip
func get_local_ip():
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "127.0.0.1" # Fallback if no local IP is found
	
## function udp broadcast
func broadcast_udp():
	udp_broadcast.set_broadcast_enabled(true)  # Allow broadcasting
	while true: # TODO Stop broadcasting when ingame
		for x in range(10):
			udp_broadcast.set_dest_address(udp_address, udp_port + x)
			var local_ip = get_local_ip()
			if GameManager.players.has(1):  # Ensure the host exists
				var message = str(len(GameManager.players)) + "|" + local_ip + "|" + str(port) + "|" + GameManager.players[1].name
				udp_broadcast.put_packet(message.to_utf8_buffer())
				#print("📤 Sent UDP Broadcast:", message)
		await get_tree().create_timer(1.0).timeout
		
func listen_udp():
	for x in range(10):
		var error = udp_listener.bind(udp_port + x, "0.0.0.0") 
		if error != OK:
			print("❌ Failed to bind UDP listener on port", udp_port + x, "Error:", error)
			continue
		print("✅ Listening on port", udp_port + x)
		break


func _process(_delta):
	while udp_listener.is_bound() and udp_listener.get_available_packet_count() > 0:
		var packet = udp_listener.get_packet().get_string_from_utf8()
		var lobby = udp_packet_to_lobby(packet)
	
		if not lobbies.has(lobby.ip):
			lobbies[lobby.ip] = lobby
			add_lobby_ui(lobby)
		elif lobbies[lobby.ip].players != lobby.players:
			lobbies[lobby.ip].players = lobby.players
			lobbies[lobby.ip].timestamp = Time.get_ticks_msec()
			modify_lobby_ui(lobby)
		else:
			lobbies[lobby.ip].timestamp = Time.get_ticks_msec()
		
	for x in lobbies:
		var t = Time.get_ticks_msec()
		var st = lobbies[x].timestamp
		if (t - st > 1500):
			remove_lobby_ui(lobbies[x])
			lobbies.erase(lobbies[x].ip)

func add_lobby_ui(lobby):
	var button = Button.new()
	button.text = lobby.host + ' (' + str(lobby.players) + '/4)'
	button.name = lobby.ip
	button.disabled = (%PlayerNameLabel.text == '')
	%LobbyListContainer.add_child(button)
	button.button_down.connect(func(): join_lobby(lobby.ip, lobby.port))

func modify_lobby_ui(lobby):
	%LobbyListContainer.get_node(str(lobby.ip).replace('.','_')).text = lobby.host + ' (' + str(lobby.players) + '/4)'

func join_lobby(ip,port):
	 #Buffer to check if the lobby still exists
	changebuttonsstate(false)
	await get_tree().create_timer(1.5).timeout
	changebuttonsstate(true)
	if not lobbies.has(ip):
		print('Error: Lobby is gone')
		return
	stop_listen_udp()
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, int(port))
	
	if error:
		print('Error: when trying to join')
		listen_udp()
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	while multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		print('waiting')
		await get_tree().create_timer(1).timeout
	
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("Error: Could not establish connection")
		peer.close()
		listen_udp()
		return
		
	
	send_to_lobby()

func remove_lobby_ui(lobby):
	var n = %LobbyListContainer.get_node(str(lobby.ip).replace('.','_'))
	n.get_parent().remove_child(n)
	n.queue_free()

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
	udp_listener.close()
	
func send_to_lobby():
	var lobby = preload("res://ui/local_lobby_ui.tscn").instantiate()
	get_tree().root.add_child(lobby)
	hide()

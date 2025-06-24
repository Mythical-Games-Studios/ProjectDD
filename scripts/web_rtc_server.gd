extends Control

enum Message{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	checkIn,
}

var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}

func _ready() -> void:
	peer.connect('peer_connected',peer_connected)
	peer.connect('peer_disconnected',peer_disconnected)
	pass
	
func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf32()
			var data = JSON.parse_string(dataString)
			print(data)
			
			if data.message == Message.lobby:
				joinLobby(data)
				
			if data.message ==  Message.offer || data.message ==  Message.answer || data.message ==  Message.candidate:
				print("source id is " + str(data.orgPeer))
				sendToPlayer(data.peer, data)
	pass

func peer_connected(id):
	print('Peer Connected: ' + str(id))
	users[id] = {
		'id': id,
		'message': Message.id
	}
	peer.get_peer(id).put_packet(JSON.stringify(users[id]).to_utf32_buffer())
	pass
func peer_disconnected(id):
	pass		

func joinLobby(user):
	var userId = int(user.id)
	var lobbyId = user.lobbyValue
	if lobbyId == '':
		lobbyId = generateRandomString(5)
		lobbies[lobbyId] = Lobby.new(userId)
		print(lobbyId)
	var player = lobbies[lobbyId].AddPlayer(userId,user.name)
	
	for p in lobbies[lobbyId].Players:
		
		var data = {
			"message" :  Message.userConnected,
			"id" : user.id
		}
		sendToPlayer(p, data)
		
		var data2 = {
			"message" :  Message.userConnected,
			"id" : p
		}
		sendToPlayer(user.id, data2)
		
		var lobbyInfo = {
			"message": Message.lobby,
			"players": JSON.stringify(lobbies[lobbyId].Players)
		}
		sentToPlayer(p,lobbyInfo)
	
	var data = {
		"message": Message.userConnected,
		"id": userId,
		"host": lobbies[lobbyId].HostID,
		"player": lobbies[lobbyId].Players[userId],
		"lobbyValue": user.lobbyValue
	}
	
	sentToPlayer(userId,data)
	
	

func sentToPlayer(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf32_buffer())
		
var lobbyChars = "PLANEWGOT"

func generateRandomString(number):
	var result = ''
	for i in range(number):
		var randomIndex = randi() % lobbyChars.length()
		result += lobbyChars[randomIndex]
	return result
	
func sendToPlayer(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf32_buffer())	
	
func startServer():
	peer.create_server(8915)
	print('Started Server')

func _on_start_server_button_down() -> void:
	startServer()
	pass # Replace with function body.


func _on_send_test_packet_2_button_down() -> void:
	var message = {
		'message':  Message.id,
		'data': "test"
	}
	var messageBytes = JSON.stringify(message).to_utf32_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.

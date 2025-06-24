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

var id = 0
var peer = WebSocketMultiplayerPeer.new()
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var lobbyValue = ''
var hostId : int

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf32()
			var data = JSON.parse_string(dataString)
			print(data)
			
			if data.message == Message.id:
				id = int(data.id)
				hostId = data.host
				lobbyValue = data.lobbyValue
				print('My ID is ' + str(id))
				connected(id)
				
			elif data.message == Message.userConnected:
				#GameManager.players[data.id] = data.player
				createPeer(data.id)
				
			elif data.message == Message.lobby:
				GameManager.players = JSON.parse_string(data.players)
				
			if data.message == Message.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("Got Candididate: " + str(data.orgPeer) + " my id is " + str(id))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid, data.index.to_int(), data.sdp)
			
			if data.message == Message.offer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			
			if data.message == Message.answer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)
	pass

#Web RTC
func createPeer(id):
	if id != self.id:
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers": [{'urls': ['stun:stun.l.google.com:19302']}]
		})
		print('binding id: ' + str(id) + ' my id: ' + str(self.id))
		
		peer.session_description_created.connect(self.offerCreated.bind(id))
		peer.ice_candidate_created.connect(self.iceCandidateCreated.bind(id))
		rtcPeer.add_peer(peer, id)
		peer.create_offer()
		
		if id < rtcPeer.get_unique_id():
			peer.create_offer()
	pass
	
func offerCreated(type, data, id):
	if !rtcPeer.has_peer(id):
		return
	
	rtcPeer.get_peer(id).connection.set_local_description(type, data)
	
	if type == 'offer':
		sendOffer(id, data)
	else:
		sendAnswer(id, data)
	pass
	
func sendOffer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" :  Message.offer,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf32_buffer())
	pass
	
func sendAnswer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" :  Message.answer,
		"data": data,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf32_buffer())
	pass
	
func iceCandiateCreated(midName, indexName, sdpName, id):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" :  Message.candidate,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"Lobby": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf32_buffer())
	pass	
	
func connectToServer(ip):
	peer.create_client('ws://127.0.0.1:8915')
	print('started client')


func _on_start_client_button_down() -> void:
	connectToServer("")
	pass # Replace with function body.


func _on_send_test_packet_button_down() -> void:
	var message = {
		'message':  Message.join,
		'data': "test"
	}
	var messageBytes = JSON.stringify(message).to_utf32_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.


func _on_join_lobby_button_down() -> void:
	var message = {
		'id': id,
		'name': 'TEST',
		'message': Message.lobby,
		'lobbyValue': $"LineEdit".text
	}
	var messageBytes = JSON.stringify(message).to_utf32_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.
	
func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer
	

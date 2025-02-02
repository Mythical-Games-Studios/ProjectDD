extends Node3D


var deck = []
var GUI = null


func getavaliableplays():
	var avp = []
	for piece in deck:
		if (piece[0] == GameManager.ground[0]) or (piece[1] == GameManager.ground[1]) or (piece[1] == GameManager.ground[0]) or (piece[0] == GameManager.ground[1]) or GameManager.ground[0] == -1:
			avp.append(piece)
	for a in avp:
		var s = str(a[0]) + '-' + str(a[1])
		GUI.enablebutton(a)
	return avp

func _ready() -> void:
	GameManager.update_hand.connect(hand_handler)
	GUI = $"../GameUI"
	if (get_parent().name != str(multiplayer.get_unique_id())):
		GUI.visible = false

func hand_handler(type,piece = null):
	# add (adds a piece)
	# clear (clears hand)
	# play (start player turn)
	# remove (remove piece)
	if type == 'add':
		deck.append(piece)
		GUI.createbutton.rpc_id(multiplayer.get_unique_id(),piece)
	elif type == 'clear':
		deck.clear()
	elif type == 'remove':
		deck.erase(piece)
		GUI.removebutton.rpc_id(multiplayer.get_unique_id(),piece)
	elif type == 'play':
		# Wait 1 second to make sure server is ready to receive signal
		await get_tree().create_timer(1).timeout
		print('Player ' + str(multiplayer.get_unique_id()) + ' turn')
		var avp = getavaliableplays()
		print(avp)
		if not len(avp):
			#GameManager.turn_finished.emit([multiplayer.get_unique_id()])
			GameManager.player_played.rpc(multiplayer.get_unique_id())
			#GameManager.turn_finished.emit(multiplayer.get_unique_id(),avp[0])
		#else:
		#await get_tree().create_timer(3).timeout
		#GameManager.turn_finished.emit()
		

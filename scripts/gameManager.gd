extends Node

var players = {}
var ground = [-1,-1]
var PT = null
var PP = null

signal update_hand(type,card)

# 28 Pieces
const DOMINOS = [
	[0,0],[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],
	[1,1],[1,2],[1,3],[1,4],[1,5],[1,6],[2,2],
	[2,3],[2,4],[2,5],[2,6],[3,3],[3,4],[3,5],
	[3,6],[4,4],[4,5],[4,6],[5,5],[5,6],[6,6]
]

var deck = DOMINOS.duplicate(true)

func _ready() -> void:
	pass
	
	
@rpc("authority",'call_local')
func reset():
	deck = DOMINOS.duplicate(true)
	update_hand.emit('clear')
	ground = [-1,-1]
	PT = null
	PP = null
	
	
@rpc("authority",'call_local')
func give_domino(piece):
	#print(multiplayer.get_unique_id())
	#print(piece)
	#pass
	update_hand.emit('add',piece)
	
@rpc("authority",'call_local')
func player_turn():
	update_hand.emit('play')
	
@rpc("any_peer",'call_local')
func played(piece):
	update_hand.emit('remove',piece)
	

@rpc('authority','call_remote')
func setup():
	if not multiplayer.is_server():
		return
	reset()
	for player in players:
		for c in range(0,7):
			var i = randi_range(0,len(deck) - 1)
			var piece = deck[i]
			deck.remove_at(i)
			give_domino.rpc_id(players[player].id,piece)


signal turn_finished

@rpc("any_peer",'call_local')
func player_played(player,piece = null):
	if PT != player:
		return
	PP = piece
	
@rpc("any_peer","call_local")
func updateground(data):
	ground = data		
	print('UPDATED GROUND ',ground)
	
@rpc("authority",'call_remote')
func game_cycle():
	# Server Only
	if not multiplayer.is_server():
		return
	
	var turn = 0; #TODO Start with the highest	
		
	while true:
		setup()
		#  round turn loop
		while true:
			var player = players.values()[turn].id
			PT = player
			player_turn.rpc_id(player)
			# Wait for either 20 seconds or the player finishing their turn
			# TODO HANDLE IT SERVER SIDE
			#var data = await turn_finished
			
			var oPP = PP
			while oPP == PP:
				await get_tree().create_timer(1).timeout
			
			var id = PT
			var piece = PP
			
			# Check if it is the correct player
			if player != id:
				return
			
			# Update ground function
			# Remove Card function
			
			if piece == null:
				print('Player has no piece')
				# Player skip or get from deck
				if len(deck):
					var i = randi_range(0,len(deck) - 1)
					var g = deck[i]
					deck.remove_at(i)
					give_domino.rpc_id(player,g)
					print('Gave: ',g)
					print('Give piece from deck, remaining: ' + str(len(deck)))
				else:
					print('SKIP')
			else:
				print('Player played')
				print(piece)
				
				# Handler for placement
				# -1 -> nothing replace completely
				# 1 side match replace with the other side
				# 2 sides equal pick first
				# 2 sides different pick first for now
				if ground[0] == -1:
					ground = piece
					
				elif ground[0] == piece[0]:
					ground[0] = piece[1]
					
				elif ground[1] == piece[0]:
					ground[1] = piece[1]
					
				elif ground[0] == piece[1]:
					ground[0] = piece[0]
					
				elif ground[1] == piece[1]:
					ground[1] = piece[0]
					
				updateground.rpc(ground)
				played.rpc_id(player,piece)
			
			
			# check if player finished function
			turn += 1;
			turn %= len(players)

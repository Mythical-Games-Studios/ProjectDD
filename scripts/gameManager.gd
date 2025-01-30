extends Node

var players = {}

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
	
	
@rpc("authority",'call_local')
func give_domino(id):
	#print(multiplayer.get_unique_id())
	#print(id)
	#pass
	update_hand.emit('add',id)
	


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

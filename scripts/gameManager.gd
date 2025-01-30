extends Node

var players = {}

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
	
	
@rpc("any_peer",'call_local')
func reset():
	deck = DOMINOS.duplicate(true)
	
	
@rpc("authority",'call_local')
func give_domino(id):
	pass
	


@rpc('authority','call_local')
func setup():
	reset()
	for player in players:
		for c in range(0,7):
			var i = randi_range(0,len(deck))
			var piece = deck[i]
			deck.remove_at(i)
		

extends Node3D


var deck = []

func _ready() -> void:
	GameManager.update_hand.connect(hand_handler)


func hand_handler(type,card = null):
	if type == 'add':
		deck.append(card)
	elif type == 'clear':
		deck.clear()
	

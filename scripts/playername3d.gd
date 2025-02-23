extends Label3D

# Ready function
func _ready() -> void:
	
	# Check if there are players
	if not len(GameManager.players): return
	
	# Get the player id from its parent name, convert it back to int
	var player_id = int(str(get_parent().name))
	
	# Get player name and change the text
	var player_name = GameManager.players[player_id].name
	self.text = player_name

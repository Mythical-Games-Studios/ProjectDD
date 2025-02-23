extends Node3D

# Exported value of the players node (set in the editor)
@export var player_node : PackedScene

# Ready function
func _ready() -> void:
	
	# Create index and get the mutiplayer id of the client
	var index = 0
	var m_id = multiplayer.get_unique_id()
	
	# Loop through each player
	for player in GameManager.players:
		
		# Create a player node and set its name to the mID of the player
		var current_player = player_node.instantiate()
		current_player.name = str(GameManager.players[player].id)
		add_child(current_player)
		
		# Get the spawn location using groups
		var spawn = get_tree().get_nodes_in_group("SpawnLocations")[index]
		
		# Set the player position and rotation to the spawn
		current_player.global_position = spawn.global_position
		current_player.global_rotation = spawn.global_rotation
		
		# Set the player camera if the player is the client
		if m_id == player:
			var cam = current_player.get_node('face/Camera3D')
			cam.make_current()
		
		# Increment (use the next spawn)
		index+=1	

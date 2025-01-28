extends Node3D


@export var PlayerScene : PackedScene

func _ready() -> void:
	var index = 0
	var mID = multiplayer.get_unique_id()
	for player in GameManager.players:
		var currentPly = PlayerScene.instantiate()
		add_child(currentPly)
		#for spawn in $SpawnLocations.get_children():
		#for spawn in get_tree().get_nodes_in_group("SpawnLocations"):
			#if spawn.name == str(index):
				#currentPly.global_position = spawn.global_position
				#if mID == GameManager.players[player].id:
					#currentPly.get_child(0).current = true
		#index += 1
		var spawn = get_tree().get_nodes_in_group("SpawnLocations")[index]
		currentPly.global_position = spawn.global_position
		currentPly.global_rotation = spawn.global_rotation
		print(currentPly.global_position)
		if mID == player:
			currentPly.get_child(0).current = true
		index+=1	

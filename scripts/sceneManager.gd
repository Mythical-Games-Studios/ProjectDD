extends Node3D


@export var PlayerScene : PackedScene

func _ready() -> void:
	var index = 0
	var mID = multiplayer.get_unique_id()
	for player in GameManager.players:
		var currentPly = PlayerScene.instantiate()
		currentPly.name = str(GameManager.players[player].id)
		add_child(currentPly)
		var spawn = get_tree().get_nodes_in_group("SpawnLocations")[index]
		currentPly.global_position = spawn.global_position
		currentPly.global_rotation = spawn.global_rotation
		if mID == player:
			var cam = currentPly.get_node('face/Camera3D')
			#cam.current = true
			cam.make_current()
		index+=1	

extends Label3D

func _ready() -> void:
		var mid = multiplayer.get_unique_id()
		if not len(GameManager.players):
			return
		var pid = int(str(get_parent().name))
		var player_name = GameManager.players[pid].name
		self.text = player_name

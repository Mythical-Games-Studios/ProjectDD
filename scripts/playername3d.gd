extends Label3D

func _ready() -> void:
		var mid = multiplayer.get_unique_id()
		if not len(GameManager.players):
			return
		var player_name = GameManager.players.get(mid).name
		self.text = player_name

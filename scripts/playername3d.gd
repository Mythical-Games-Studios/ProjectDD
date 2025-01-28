extends Label3D

func _ready() -> void:
	var mid = multiplayer.get_unique_id()
	var name = GameManager.players.get(mid).name
	self.text = name

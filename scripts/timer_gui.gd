extends Label

var timer
@export var change = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = $Timer
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if not change: return
	
	var t = timer.time_left
	t = str(int(t))
	text = t

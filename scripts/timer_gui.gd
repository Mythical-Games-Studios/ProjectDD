extends Label

# Variable for time and an export value of when to allow change it
var timer
@export var change = false

# Called when the node enters the scene tree for the first time.
# Sets the timer node
func _ready() -> void:
	timer = $Timer

# Called every 0.2 seconds
func _physics_process(delta: float) -> void:
	# Check if it will change (players turn) otherwise ignore
	if not change: return
	
	# Get the remaining timer, convert it to int then string for text display
	var time_remaining = timer.time_left
	time_remaining = str(int(time_remaining))
	text = time_remaining

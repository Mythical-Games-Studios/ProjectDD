extends Control

var container = null
var cards = null

@rpc("authority","call_local")
func createbutton(value):
	var button = Button.new()
	button.name = str(value[0]) + '-' + str(value[1]) 
	button.text = str(value)
	button.set_h_size_flags(SIZE_SHRINK_CENTER)
	container.add_child(button)
	button.pressed.connect(func(): pressed(button,value))
	button.disabled = true

@rpc("authority","call_local")
func removebutton(value):
	var n = str(value[0]) + '-' + str(value[1]) 
	var button = container.get_node(n)
	container.remove_child(button)
	button.queue_free()
	

func pressed(button,value):
	var c = value.duplicate(true)
	c.append(multiplayer.get_unique_id())
	#print(value)
	#GameManager.turn_finished.emit(c)
	GameManager.player_played.rpc(multiplayer.get_unique_id(),value)
	GameManager.playerfinished.rpc(len(container.get_children()) - 1 == 0)
	disableall()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container = $PanelContainer/GridContainer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func enablebutton(value):
	var n = str(value[0]) + '-' + str(value[1]) 
	container.get_node(n).disabled = false
	
func disableall():
	var c = container.get_children()
	for i in c:
		i.disabled = true
		
func reset():
	#container
	pass
	#TODO 

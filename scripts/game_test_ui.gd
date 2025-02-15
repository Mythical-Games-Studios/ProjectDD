extends Control

var container = null
var cards = null

@rpc("authority","call_local")
func createbutton(value):
	var button = TextureButton.new()
	var bn = str(value[0]) + '-' + str(value[1]) 
	button.name = bn
	#button.text = str(value)
	button.texture_normal = CardTextures.root[bn]
	#button.set_h_size_flags(SIZE_SHRINK_CENTER)
	button.custom_minimum_size = Vector2(int($PanelContainer.size.x / 14), int($PanelContainer.size.y))
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(button)
	button.pressed.connect(func(): pressed(button,value))
	button.disabled = true
	button.modulate = Color(0.5,0.5,0.5,1)

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
	container.get_node(n).modulate = Color.WHITE
	
func disableall():
	var c = container.get_children()
	for i in c:
		i.disabled = true
		i.modulate = Color(0.5,0.5,0.5,1)
func reset():
	#container
	pass
	#TODO 
	
func updateground(value):
	$GroundText.text = 'Ground: ' + str(value)
	

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
	
@rpc("authority","call_local")
func clear():
	for x in container.get_children():
		container.remove_child(x)
		x.queue_free()
	

func pressed(button,value):
	var c = value.duplicate(true)
	c.append(multiplayer.get_unique_id())
	stoptimer()
	#print(value)
	#GameManager.turn_finished.emit(c)
	GameManager.player_played.rpc(multiplayer.get_unique_id(),value)
	GameManager.playerfinished.rpc(len(container.get_children()) - 1 == 0)
	disableall()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container = $PanelContainer/GridContainer
	setupleadergui()
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
	
func starttimer():
	$TimerGUI.change = true;
	$TimerGUI/Timer.start()
	$TimerGUI.visible = true
	
func timeout():
	#var c = [null]# value.duplicate(true)
	#c.append(multiplayer.get_unique_id())
	#print(value)
	#GameManager.turn_finished.emit(c)
	GameManager.player_played.rpc(multiplayer.get_unique_id(),null)
	#GameManager.playerfinished.rpc(len(container.get_children()) - 1 == 0)
	disableall()

func stoptimer():
	$TimerGUI.change = false;
	$TimerGUI/Timer.stop()
	$TimerGUI.visible = false

func _on_timer_timeout() -> void:
	print('Out of time')
	$TimerGUI/Timer.stop()
	timeout()
	$TimerGUI.visible = false
	
func setupleadergui():
	var players = GameManager.players
	var entryUI = $LeaderboardContainer/GridContainer/Entry
	var parent = $LeaderboardContainer/GridContainer
	for x in parent.get_children():
		if x == entryUI:
			continue
		parent.remove_child(x)
		x.queue_free()
	
	for i in players:
		var cloneUI = entryUI.duplicate()
		parent.add_child(cloneUI)
		cloneUI.name = 'Entry ' + str(i)
		cloneUI.visible = true
		cloneUI.get_node('Username').text = players[i].name
		cloneUI.get_node('Score').text = str(players[i].score)
		
func updateleadergui():
	var parent = $LeaderboardContainer/GridContainer
	for pid in GameManager.players:
		var node = parent.get_node('Entry ' + str(pid))
		node.get_node('Score').text = str(GameManager.players[pid].score)
	
func displayleadergui():
	var parent = $LeaderboardContainer
	parent.visible = true
	await  get_tree().create_timer(5).timeout
	parent.visible = false
	
func displaygamestatgui(message):
	var parent = $GameStatusLabel
	parent.text = message
	parent.visible = true
	await  get_tree().create_timer(1.5).timeout
	parent.visible = false

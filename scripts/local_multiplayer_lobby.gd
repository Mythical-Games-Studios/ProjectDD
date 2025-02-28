extends Control

func getPlayerNames():
	# get container
	var players_container = %PlayersPanel.get_child(0)
	
	# loop through text if player has left
	for label in players_container.get_children():
		if GameManager.players.get(str(label.name)): continue
		players_container.remove_child(label)
		label.queue_free()
	
	# loop through players
	for player_id in GameManager.players:
		var player_name = GameManager.players[player_id].name
		
		# check if text is there, skip
		var exists = players_container.get_node_or_null(player_name+'_ID')
		if exists: continue
		
		# create margin container
		var m_container = MarginContainer.new()
		m_container.name = str(player_id) + '_ID'
		var margin_value = 8
		m_container.add_theme_constant_override("margin_top", margin_value)
		m_container.add_theme_constant_override("margin_left", margin_value)
		m_container.add_theme_constant_override("margin_bottom", margin_value)
		m_container.add_theme_constant_override("margin_right", margin_value)
		players_container.add_child(m_container)
		
		# create hsplit
		var h_split = HSplitContainer.new()
		h_split.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
		m_container.add_child(h_split)
			
		# create label
		var label = Label.new()
		label.name = 'PlayerNameLabel'
		label.text = player_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h_split.add_child(label)
		
		if multiplayer.is_server() and player_id != 1:
			# create kick button
			var kick = Button.new()
			kick.name = 'KickButton'
			kick.text = 'Kick'
			kick.button_down.connect(func(): kick_player(player_id))
			h_split.add_child(kick)
		
	# change player count
	changePlayerCount()
	
# change player count 
func changePlayerCount():
	
	# get len players then set it to the UI
	var c = len(GameManager.players)
	%PlayerCountLabel.text = 'Player Count (' + str(c) + '/4)'
	
func _ready() -> void:
	multiplayer.peer_connected.connect(updatePlayers)
	multiplayer.peer_disconnected.connect(updatePlayers)
	getPlayerNames()
	
#@rpc("authority", "call_local", "reliable")
func updatePlayers(arg):
	# buffer for game manager
	await get_tree().create_timer(0.1).timeout
	getPlayerNames()
	
	if multiplayer.get_unique_id() == 1:
		set_state_start(len(GameManager.players) > 1)



func set_state_start(state):
	state = not state
	%StartButton.disabled = state




func _on_start_button_button_down() -> void:
	
	# Only have host start
	if multiplayer.get_unique_id() != 1:
		return	
		
	# rpc call to start the game	
	startGame.rpc()

# rpc to start game	
@rpc("authority", "call_local", "reliable")
func startGame():
	
	# load world
	var scene = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	
	# hide this ui
	self.hide()
	
	#print('START')
	
	# set gamemanager variables
	GameManager.world = scene
	GameManager.mui = self
	GameManager.ingame = true
	
	# start game cycle
	GameManager.game_cycle()


func _on_back_button_button_down() -> void:
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			remove_player.rpc_id(peer)
			
	await  get_tree().create_timer(0.3).timeout
	remove_player()

@rpc("authority", "call_remote", "reliable")
func remove_player():
	multiplayer.multiplayer_peer.close()
	get_tree().root.remove_child(self)
	queue_free()
	
func kick_player(id):
	remove_player.rpc_id(id)
	print('Kicked ',id)

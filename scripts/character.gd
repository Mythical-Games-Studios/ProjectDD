extends CharacterBody3D

# Set up consants and variables
const maximum_rotation = 70
const mouse_sensitivity = 0.3
var applied_rotation_y = 0
var applied_rotation_x = 0
var camera = null

# Fire on input
func _input(event: InputEvent) -> void:
	# Check if input came from that client only
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	# Check if its a mouse moved event
	if event is InputEventMouseMotion:
		
		# Set the required rotation of both x and y based on how much is moved as well as the users sensitivity
		# TODO: Make user be able to edit their sensitivity
		var addional_rotation_y = -event.relative.x * mouse_sensitivity # x on screen
		var addional_rotation_x = -event.relative.y * mouse_sensitivity # y on screen
		
		# check if rotation is valid for y [-70,70] then apply it
		if (applied_rotation_y < maximum_rotation and addional_rotation_y > 0) or (applied_rotation_y > -maximum_rotation and addional_rotation_y < 0):
			applied_rotation_y += addional_rotation_y 
			camera.rotation.y += (deg_to_rad(addional_rotation_y))
			
		# check if rotation is valid for x [-70,70] then apply it	
		if (applied_rotation_x < maximum_rotation and addional_rotation_x > 0) or (applied_rotation_x > -maximum_rotation and addional_rotation_x < 0):
			applied_rotation_x += addional_rotation_x 
			camera.rotation.z += (deg_to_rad(addional_rotation_x))

# Ready function	
func _ready() -> void:
	
	# Sets up camera, mutisync
	# TODO: set up mouse to lock
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())
	camera = $face

# TODO: add controller support, remove un-used code
#func _physics_process(delta):
	#print(GameManager.playerdeck)
	#pass
		# Add the gravity.
		#if not is_on_floor():
			#velocity.y -= gravity * delta
			#
		## Handle Jump.
		#if Input.is_action_just_pressed("jump") and is_on_floor():
			#velocity.y = JUMP_VELOCITY
		#
		#syncPos = global_position
		#syncRot = rotation_degrees
		##if Input.is_action_just_pressed("Fire"):
		## Get the input direction and handle the movement/deceleration.
		## As good practice, you should replace UI actions with custom gameplay actions.
		##var direction = Input.get_axis("ui_left", "ui_right")
		##if direction:
		#if Input.is_action_just_pressed("move-forward"):
			#velocity.x = delta * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
#
		#move_and_slide()

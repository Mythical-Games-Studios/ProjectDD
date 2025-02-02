extends CharacterBody3D


const MAX_ANGLE = 90
const MOUSE_SEN = 0.3
var rot_y = 0
var rot_x = 0

func _input(event: InputEvent) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	if event is InputEventMouseMotion:
		var CAMERA = $face#/Camera3D
		var rotation_deg = CAMERA.rotation_degrees
		var reqroty = -event.relative.x * MOUSE_SEN
		var reqrotx = -event.relative.y * MOUSE_SEN
		if (rot_y < 70 and reqroty > 0) or (rot_y > -70 and reqroty < 0):
			rot_y += reqroty 
			CAMERA.rotate_y(deg_to_rad(reqroty))
		#if (rot_x < 70 and reqrotx > 0) or (rot_x > -70 and reqrotx < 0):
			#rot_x += reqrotx 
			#CAMERA.rotation.x += (deg_to_rad(reqrotx))
	
func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())



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

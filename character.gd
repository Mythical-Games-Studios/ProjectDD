extends CharacterBody3D


const MAX_ANGLE = 90
const MOUSE_SEN = 0.3

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var rotation = $face.rotation_degrees
		print(rotation.y, ' ', -event.relative.x)
		if (rotation.y < 90 and -event.relative.x > 0) or (rotation.y > -90 and -event.relative.x < 0):
			$face.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SEN))
	
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _physics_process(delta):
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

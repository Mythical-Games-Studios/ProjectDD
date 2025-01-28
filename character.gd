extends CharacterBody3D



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var syncPos = Vector2(0,0)
var syncRot = 0
const SPEED = 300.0
const JUMP_VELOCITY = 400.0

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

extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_movement := Input.get_axis("move_left","move_right")
	if x_movement:
		velocity.x = x_movement * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var y_movement := Input.get_axis("move_up","move_down")
	if y_movement:
		velocity.y = y_movement * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _kill():
	queue_free()

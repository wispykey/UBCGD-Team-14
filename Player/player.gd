extends CharacterBody2D

"""
Player movement-related functionality should exist here.
"""

# TODO: Signal to tell the TileManager which tile(s) to light up

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Symbol '%' means "Get a reference to the unique node with this name"
@onready var hud = %HUD
@onready var tile_manager = %TileManager

# To check for valid movement. 
@onready var walls = %TileManager.walls

# TODO: Implement grid-based movement (and delete 'normal' movement)

# TODO: Emit a signal to light up tiles

# TODO: Implement double-tap dash

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

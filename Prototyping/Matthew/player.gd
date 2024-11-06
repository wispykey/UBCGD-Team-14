extends CharacterBody2D

@onready var tileMap = get_node("Prototyping/Background")
@onready var conductor = get_node("/root/Conductor")

var move_cd_timer: float = 0.0
var move_cd_interval: float = 0.0

const TILE_SIZE: int = 32
const PLAYER_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 480

# uncomment for smooth movement
# const SPEED = 5.0
# const JUMP_VELOCITY = -400.0

func _ready() -> void:
	position.x = 45
	position.y = 434
	move_cd_interval = conductor.seconds_per_eighth_note  # Directly access the conductor's variable
	print("seconds per eighth? ", move_cd_interval)
	move_cd_timer = move_cd_interval
	# var connection_result = conductor.connect("eighth_note_duration_ready", _on_eighth_note_duration_ready)
	
# func _on_eighth_note_duration_ready(duration: float) -> void:
	# print("Received eighth note duration: ", duration)
	# var fps = Engine.get_frames_per_second()
	# var frames_float = fps * duration
	# move_cd_in_frames = round(frames_float)
	# print("Eighth note duration (in seconds): ", duration)
	# print("Cooldown in frames: ", move_cd_in_frames)

func _physics_process(delta: float) -> void:
	move_cd_timer -= delta  # Cooldown for movement reduces over time
	# var new_position = position

	# Check if cooldown is over before processing input
	if move_cd_timer <= 0:
		# Movement with `is_action_pressed` for reliable input
		if Input.is_action_pressed("move_right") and canMoveRight():
			# new_position.x = position.x + TILE_SIZE
			position.x += TILE_SIZE
			move_cd_timer = move_cd_interval
			print("Moved right")
		elif Input.is_action_pressed("move_left") and canMoveLeft():
			# new_position.x = position.x - TILE_SIZE
			position.x -= TILE_SIZE
			move_cd_timer = move_cd_interval
		elif Input.is_action_pressed("move_up") and canMoveUp():
			# new_position.y = position.y - TILE_SIZE
			position.y -= TILE_SIZE
			move_cd_timer = move_cd_interval
		elif Input.is_action_pressed("move_down") and canMoveDown():
			# new_position.y = position.y + TILE_SIZE
			position.y += TILE_SIZE
			move_cd_timer = move_cd_interval
	
	# Need debugging for not running into new walls
	# if !is_position_blocked(new_position):
		# position = new_position
		# print("Moved to: ", new_position)
	# else:
		# print("Ran into wall!")
		
# func is_position_blocked(position: Vector2) -> bool:
	# Convert the world position to the tilemap's grid position
	# var tile_pos = position / TILE_SIZE
	
	# Get the cell ID at the player's new position
	# var cell_id = tileMap.get_cell_source_id(tile_pos)
	
	# return cell_id == 1  


func canMoveLeft() -> bool:
	return (position.x > TILE_SIZE + PLAYER_SIZE)
func canMoveRight() -> bool:
	return (position.x < WIDTH - PLAYER_SIZE - TILE_SIZE)
func canMoveUp() -> bool:
	return (position.y > TILE_SIZE + PLAYER_SIZE)
func canMoveDown() -> bool:
	return (position.y < HEIGHT - PLAYER_SIZE - TILE_SIZE)

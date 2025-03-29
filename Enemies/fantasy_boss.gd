extends AnimatedSprite2D

var speed = 1
var direction: Vector2
var window_dimensions
var y_offset = 0
var bob_direction = 0
var bob_speed = 0.5
var can_move = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window_dimensions =  GameState.control_port.size
	direction = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_move:
		if direction == Vector2.ZERO:
			random_start()
		else:
			random_stop()
		move()
		check_bounds()
		bob()

func check_bounds():
	if position.x > window_dimensions.x - 64 or position.y > window_dimensions.y -64 or position.x < 64 or position.y < 64:
		direction.x = -direction.x
		direction.y = -direction.y

func generate_new_direction():
	direction.x = randf_range(-1, 1)
	direction.y = randf_range(-1, 1)

func move():
	position.x += direction.x * speed
	position.y += direction.y * speed

func random_stop():
	var rng = randi_range(0, 29)
	if rng == 29:
		direction = Vector2.ZERO

func random_start():
	var rng = randi_range(0, 14)
	if rng == 9:
		generate_new_direction()

func bob():
	if y_offset >= 5:
		bob_direction = 0
	if y_offset <= -5:
		bob_direction = 1
	if !bob_direction:
		position.y -= bob_speed
		y_offset -= 1
	else:
		position.y += bob_speed
		y_offset += 1

extends Line2D


const SEGMENT_LENGTH: float = 24.0

var x_center: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	x_center = to_global(position).x
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	$HitZone.monitorable = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if $TelegraphTimer.is_stopped():
		generate_path()

# Build a random zig-zag path from spawn position to a location off-screen
func generate_path():
	clear_points()
	add_point(Vector2.ZERO)
	# Current point is aAlways the highest point in the line
	var curr_point = points[0] 
	var loops = 30
	while is_on_screen(to_global(curr_point)) and loops > 0:
		var next_point = get_next_point(curr_point)
		add_point(next_point)
		curr_point = next_point
		loops -= 1

# Gets next point using weighted probabilities based on previous point
func get_next_point(prev_point: Vector2):
	var offset = randf_range(0.3, 0.9)
	if prev_point.x == 0:
		offset *= 16.0
		if int(Conductor.num_beats_passed) % 2:
			offset *= -1
	elif prev_point.x > 0:
		offset *= -32.0
	else:
		offset *= 32.0

	return Vector2(offset, prev_point.y - SEGMENT_LENGTH)
	
func _on_telegraph_timer_timeout():
	$Telegraph.queue_free()
	$DespawnTimer.start()
	$HitZone.monitorable = true

func _on_despawn_timer_timeout():
	queue_free()

func is_on_screen(point: Vector2):
	return point.y >= 0.0

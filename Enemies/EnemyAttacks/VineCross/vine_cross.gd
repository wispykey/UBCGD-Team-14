extends Node2D


var growth_rate: int = 150
var all_directions_finished: bool = false

# The longest distance any vine has to travel before hitting wall
var longest_distance: int

var vines = []
# Order is coupled with vines
var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vines = [$XAxis/Right, $XAxis/Left, $YAxis/Up, $YAxis/Down]
	compute_furthest_direction()
	
	$TelegraphTimer.wait_time = 4 * Conductor.seconds_per_quarter_note
	$LifetimeTimer.wait_time = 10 * Conductor.seconds_per_quarter_note
	

func compute_furthest_direction():
	var spawn_position = global_position
	
	# Since we have one layer of 'wall' in arena, we can just use arena size
	var to_left_wall = spawn_position.x
	var to_right_wall = GameState.control_port.end.x - spawn_position.x
	var to_upper_wall = spawn_position.y
	var to_lower_wall = GameState.control_port.end.y - spawn_position.y

	longest_distance = max(to_left_wall, to_right_wall, to_upper_wall, to_lower_wall)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_collision_regions()
	
	if !$TelegraphTimer.is_stopped():
		return 
	if !all_directions_finished:
		grow(delta)
	elif all_directions_finished and $LifetimeTimer.is_stopped():
		recede(delta)


func grow(delta: float):
	for i in range(len(vines)):
		var vine = vines[i]
		var last_point = vine.points[vine.get_point_count()-1]
		var new_point = last_point + delta*directions[i]*growth_rate
		vine.add_point(new_point)
		check_finished(new_point)
	
func update_collision_regions():
	$XAxis.update_collision_region($XAxis/Right/Head.position.x)
	$YAxis.update_collision_region($YAxis/Down/Head.position.y)
		
	
func recede(delta: float):
	for i in range(len(vines)):
		var vine = vines[i]
		if (vine.points.size() > 2):
			var point_to_remove = vine.points[vine.points.size()-1]
			vine.remove_point(vine.points.size()-1)

func check_finished(point):
	if point.x > longest_distance or point.y > longest_distance:
		all_directions_finished = true
		$LifetimeTimer.start()

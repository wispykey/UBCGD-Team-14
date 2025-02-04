extends Node2D

@export var telegraph_image: PackedScene
@export var attack_image: PackedScene

const DIRECTIONS = ["WEST", "EAST", "NORTH", "SOUTH"]
const TILE_SIZE = 32

var telegraph_rect
var telegraph_duration: int  = 4 # Measured in beats
# Width x Height of the attack, measured in tiles
var direction: String = ""
var dimensions: Vector2 # Measured in tiles
var coords: Vector2 # Measured in tiles

var window_dimensions
var half_width
var half_height
var telegraph_dur_sec
var size_tween
var pos_tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	# Disable collisions during telegraph
	$HitZone.monitorable = false
	$HitZone.monitoring = false
	
	window_dimensions =  get_viewport_rect().size
	half_width = window_dimensions.x/2
	half_height = window_dimensions.y/2
	telegraph_dur_sec = $TelegraphTimer.wait_time
	
	telegraph_rect = ColorRect.new()
	size_tween = create_tween()
	pos_tween = create_tween()


func start(direction: String):
	set_direction(direction)
	
	normalize_position()
	compute_dimensions()
	generate_collision_area()
	
	create_telegraph_rectangle()
	$TelegraphTimer.start()
	#add_scene_on_every_tile($Telegraph, telegraph_image)
	
	
	
# Allows parent nodes to set orientation of attack
func set_direction(cardinal: String):
	# Default to West on invalid input
	if cardinal not in DIRECTIONS:
		direction = "WEST"
	else:
		direction = cardinal


func add_scene_on_every_tile(parent: Node2D, scene: PackedScene):
	var x_offset: float = 0
	var y_offset: float = 0
	var x_invert: int = 1
	var y_invert: int = 1
	
	print(direction)
	match direction:
		"WEST":
			x_invert = -1
			y_offset = -floor(dimensions.y/2)
		"EAST":
			y_offset = -floor(dimensions.y/2)
		"NORTH":
			y_invert = -1
			x_offset = -floor(dimensions.x/2)
		"SOUTH":
			x_offset = -floor(dimensions.x/2)
		
	for i in dimensions.x:
		for j in dimensions.y:
			var telegraph = scene.instantiate()
			telegraph.position.x = x_invert * TILE_SIZE*(i + x_offset)
			telegraph.position.y = y_invert * TILE_SIZE*(j + y_offset)
			parent.add_child(telegraph)	

func create_telegraph_rectangle():
	telegraph_rect.color = Color(1, 0, 0, 0.3)  # Semi-transparent red
	add_child(telegraph_rect)

	size_tween = create_tween() # between; interpolated object
	pos_tween = create_tween() 
	
	# Calculate final size based on direction
	match direction:
		"EAST": # Left to Right -->
			telegraph_rect.position = Vector2(-TILE_SIZE/2, -half_height) # Top Center
			telegraph_rect.size = Vector2(0, window_dimensions.y) # Height of screen
			size_tween.tween_property(telegraph_rect, "size:x", dimensions.x * TILE_SIZE + TILE_SIZE, telegraph_dur_sec)
		
		"WEST":  # Right to Left
			telegraph_rect.position = Vector2(TILE_SIZE/2, -half_height) # Top center
			telegraph_rect.size = Vector2(0, window_dimensions.y)
			pos_tween.tween_property(telegraph_rect, "position:x", -half_width, telegraph_dur_sec)
			size_tween.tween_property(telegraph_rect, "size:x", dimensions.x * TILE_SIZE + TILE_SIZE,telegraph_dur_sec)
		
		"SOUTH": # Top to Bottom
			telegraph_rect.position = Vector2(-half_width, -TILE_SIZE/2)
			telegraph_rect.size = Vector2(window_dimensions.x, 0)
			size_tween.tween_property(telegraph_rect, "size:y", dimensions.y * TILE_SIZE, telegraph_dur_sec)

		"NORTH": # Bottom to Top
			telegraph_rect.position = Vector2(-half_width, TILE_SIZE/2)
			telegraph_rect.size = Vector2(window_dimensions.x, 0)
			pos_tween.tween_property(telegraph_rect, "position:y", -half_height, telegraph_dur_sec)
			size_tween.tween_property(telegraph_rect, "size:y", dimensions.y * TILE_SIZE + TILE_SIZE, telegraph_dur_sec)

	# Ensure telegraph disappears before the attack starts
	size_tween.tween_callback(func(): telegraph_rect.queue_free())
	#pos_tween.tween_callback(func(): telegraph_rect.queue_free())
	

func normalize_position():
	var viewport = get_viewport_rect()
	var center = viewport.get_center()
	
	# Originate from center of arena by default
	if position == Vector2.ZERO:
		position.x = center.x
		position.y = center.y
		
	# Center along an axis where appropriate
	match direction:
		"WEST", "EAST":
			position.y = center.y
		"NORTH", "SOUTH":
			position.x = center.x
	
	# Get the position of top-left corner of the bounding tile
	var x = int(position.x) - int(position.x) % TILE_SIZE
	var y = int(position.y) - int(position.y) % TILE_SIZE
	
	## Set position to be the middle of tile, so that images appear centered
	#position.x = x + TILE_SIZE / 2
	#position.y = y + TILE_SIZE / 2
	
	# Store grid-based coordinates
	coords.x = x / TILE_SIZE
	coords.y = y / TILE_SIZE
			
			
func compute_dimensions():
	var viewport = get_viewport_rect()
	var max_x = viewport.size.x / TILE_SIZE
	var max_y = viewport.size.y / TILE_SIZE
	
	# Include the column/row that the attacker is standing on
	match direction:
		"WEST":
			dimensions.x = coords.x   # -1: Don't extend into wall
			dimensions.y = max_y - 2  # -2: Don't extend into walls 
		"EAST":
			dimensions.x = max_x - coords.x - 1  
			dimensions.y = max_y - 2
		"NORTH":
			dimensions.x = max_x - 2
			dimensions.y = coords.y
		"SOUTH":
			dimensions.x = max_x - 2
			dimensions.y = max_y - coords.y - 1
			
	print("Cleaving ", direction, " from tile ", coords,
		  ", in a ", dimensions.x, "x", dimensions.y, " area")


# HitZone is intentionally missing CollisionShape. Added here.
func generate_collision_area():
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = dimensions * TILE_SIZE
	collision_shape.set_shape(rect_shape)
	$HitZone.add_child(collision_shape)
	match direction:
		"EAST":
			$HitZone.position.x = (dimensions.x-1) * TILE_SIZE/2.0
		"WEST":
			$HitZone.position.x = -(dimensions.x-1) * TILE_SIZE/2.0
		"NORTH":
			$HitZone.position.y = -(dimensions.y-1) * TILE_SIZE/2.0
		"SOUTH":
			$HitZone.position.y = (dimensions.y-1)* TILE_SIZE/2.0
	

func _on_telegraph_timer_timeout():
	# Enable collision area
	$HitZone.monitoring = true
	$HitZone.monitorable = true

	# Could be optimized to avoid adding more children
	$Telegraph.visible = false
	add_scene_on_every_tile(self, attack_image)
	$DespawnTimer.start()
			
			
func _on_despawn_timer_timeout():
	call_deferred("queue_free")
	

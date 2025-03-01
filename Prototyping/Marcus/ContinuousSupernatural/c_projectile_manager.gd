extends Node2D

@onready var player: CharacterBody2D = $"../Player"

const TILE_SIZE = 32

@export var t_img_left: PackedScene
@export var t_img_right: PackedScene
@export var t_img_up: PackedScene
@export var t_img_down: PackedScene

@export var projectile_instance: PackedScene
var screen_size: Vector2
var spawn_timer: Timer
var telegraph_duration: int = 4 # Measured in beats
var type
var coords
var direction


# Straight projectiles will always be from edge of screen
# Arguments: Row, Col, Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size.x = 160
	screen_size.y = 160
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)

func start_spawning():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0 # can adjust to change spawn rate
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	
	# NOTE: Temporarily spawning only circles until 'path' and 'straight' are fixed
	#spawn_timer.timeout.connect(_spawn_circle_projectile)
	#spawn_timer.connect("timeout", Callable(self, "_spawn_projectile"))
	
	add_child(spawn_timer)

func add_telegraph_image(direction: String, coord: Vector2):
	match direction:
		"LEFT":
			add_scene($Telegraph, t_img_left, coord)
		"RIGHT":
			add_scene($Telegraph, t_img_right, coord)
		"UP":
			add_scene($Telegraph, t_img_up, coord)
		"DOWN":
			add_scene($Telegraph, t_img_down, coord)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func spawn_projectiles(type: int, coords: PackedVector2Array, direction: String):
	self.type = type
	self.coords = coords
	self.direction = direction
	
	match type:
		0:
			for coord in coords:
				start_straight_projectile(coord, direction)
		1:
			_spawn_path_projectile()
		2:
			_spawn_circle_projectile()
		_: # (optional)
			for coord in coords:
				start_straight_projectile(coord, direction)

func start_straight_projectile(start_coord: Vector2i, direction: String):
	add_telegraph_image(direction, start_coord)
	$TelegraphTimer.start()

func _spawn_straight_projectile(start_coord: Vector2i, direction: String):
	var projectile = projectile_instance.instantiate()
	projectile.follow_type = 0
		
	projectile.position = Vector2(start_coord.x * 32, start_coord.y * 32) + Vector2(TILE_SIZE/2, TILE_SIZE/2) # Assuming 32px per tile

	# Set direction of movement based on the provided string
	match direction:
		"UP": projectile.direction = Vector2(0, -1)
		"DOWN": projectile.direction = Vector2(0, 1)
		"LEFT": projectile.direction = Vector2(-1, 0)
		"RIGHT": projectile.direction = Vector2(1, 0)
		_:
			print("Invalid direction")
	
	get_parent().add_child(projectile)

#func start(input_direction: String, input_type: String, input_coords: PackedVector2Array, input_turn_count: int):
	#set_direction(input_direction)
	#set_attack_type(input_type)
	#
	#for coord in input_coords:
		#var projectile = projectile_instance.instantiate()
		#projectiles.append(projectile)
		#add_child(projectile)
		#projectile.start(direction, coord)
		#starting_coords.append(coord)
	#turn_count = input_turn_count
	#$TelegraphTimer.start()
	#add_telegraph_image()

func _spawn_circle_projectile():
	var projectile_count = 8  # Number of projectiles to spawn
	var radius_increment = 1  # Adjust this value to control how far apart the projectiles spawn
	var angle_step = 2 * PI / projectile_count  # 2 * PI (360°) divided by the number of projectiles
	# NOTE: Changed center_position from Vector2(0,0) to the center of our game window
	var center_position = get_viewport_rect().get_center()  # Center of the spiral
	var start_angle = randf_range(0, 2 * PI)  # Random starting angle to vary the spiral
	
	# Spawn all projectiles at the center position
	for i in range(projectile_count):
		var projectile = projectile_instance.instantiate()
		var angle = start_angle + angle_step * i
		var radius = radius_increment * (i + 1)
		
		projectile.position = center_position + Vector2(cos(angle), sin(angle)) * radius
		projectile.direction = Vector2(cos(angle), sin(angle))  # Outward direction
		projectile.follow_type = 2
		
		# Add the projectile to the scene
		get_parent().add_child(projectile)
		#print("Spawning projectile at: ", projectile.position)


func _spawn_path_projectile():
	var projectile = projectile_instance.instantiate()
	projectile.position = Vector2(-screen_size.x, randf_range(-110, 110)) # Bottom
	projectile.follow_type = 1
	print("Path projectile created at ", projectile.position)
	get_parent().add_child(projectile)
	

func _on_telegraph_timer_timeout():
	$Telegraph.visible = false
	for coord in coords:
		_spawn_straight_projectile(coord, direction)
	#add_scene(self)
	#Conductor.quarter_beat.connect(update)

func add_scene(parent: Node2D, scene: PackedScene, coord: Vector2):
	var sprite = scene.instantiate()
	sprite.position = coord * TILE_SIZE + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	parent.add_child(sprite)

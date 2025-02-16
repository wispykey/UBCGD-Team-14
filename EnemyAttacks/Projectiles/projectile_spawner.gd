extends Node2D

@onready var player: CharacterBody2D = $"../Player"

var projectile_scene = preload("res://EnemyAttacks/Projectiles/projectile.tscn")
var screen_size: Vector2
var spawn_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size.x = 160
	screen_size.y = 160
	start_spawning()

func start_spawning():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0 # can adjust to change spawn rate
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	
	# NOTE: Temporarily spawning only circles until 'path' and 'straight' are fixed
	spawn_timer.timeout.connect(_spawn_circle_projectile)
	#spawn_timer.connect("timeout", Callable(self, "_spawn_projectile"))
	
	add_child(spawn_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _spawn_projectile():
	var random_choice = randi() % 3
	
	if random_choice == 0:
		_spawn_straight_projectile()
	elif random_choice == 1:
		_spawn_path_projectile()
	elif random_choice == 2:
		_spawn_circle_projectile()


func _spawn_circle_projectile():
	var projectile_count = 8  # Number of projectiles to spawn
	var radius_increment = 1  # Adjust this value to control how far apart the projectiles spawn
	var angle_step = 2 * PI / projectile_count  # 2 * PI (360°) divided by the number of projectiles
	# NOTE: Changed center_position from Vector2(0,0) to the center of our game window
	var center_position = get_viewport_rect().get_center()  # Center of the spiral
	var start_angle = randf_range(0, 2 * PI)  # Random starting angle to vary the spiral
	
	# Spawn all projectiles at the center position
	for i in range(projectile_count):
		var projectile = projectile_scene.instantiate()
		var angle = start_angle + angle_step * i
		var radius = radius_increment * (i + 1)
		
		projectile.position = center_position + Vector2(cos(angle), sin(angle)) * radius
		projectile.direction = Vector2(cos(angle), sin(angle))  # Outward direction
		projectile.follow_type = 2
		
		# Add the projectile to the scene
		get_parent().add_child(projectile)
		#print("Spawning projectile at: ", projectile.position)


func _spawn_path_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.position = Vector2(-screen_size.x, randf_range(-110, 110)) # Bottom
	projectile.follow_type = 1
	print("Path projectile created at ", projectile.position)
	get_parent().add_child(projectile)
	

func _spawn_straight_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.follow_type = 0
	
	# Randomly picks an edge (out of 4)
	var edge = randi() % 4
		
	match edge:
		# Assigns it at a random location based on the edge it picked
		0:
			projectile.position = Vector2(randf_range(-160, 160), 0) # Top
		1:
			projectile.position = Vector2(randf_range(-160, 160), screen_size.y) # Bottom
		2:
			projectile.position = Vector2(0, randf_range(-160, 160)) # Left
		3:
			projectile.position = Vector2(screen_size.x, randf_range(-160, 160)) # Right
		# Setting the direction it heads towards
	if player:
		projectile.direction = (player.position - projectile.position).normalized()
	else:
		print("no player!")
	get_parent().add_child(projectile)

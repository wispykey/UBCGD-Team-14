extends Node2D

#TODO: Add terrian collision so the projectile disappers when it hit a wall
#TODO: Implement other types of projectiles

@onready var player_coords

@export var telegraph_image_west: PackedScene
@export var telegraph_image_east: PackedScene
@export var telegraph_image_north: PackedScene
@export var telegraph_image_south: PackedScene
@export var telegraph_image_expanding: PackedScene
@export var telegraph_image_spinning_west: PackedScene
@export var telegraph_image_spinning_east: PackedScene
@export var telegraph_image_spinning_north: PackedScene
@export var telegraph_image_spinning_south: PackedScene
@export var telegraph_image_tracking: PackedScene
@export var generate_projectile: PackedScene

const DIRECTIONS = ["WEST", "EAST", "NORTH", "SOUTH"]
const TYPE = ["STRAIGHT", "EXPANDING", "SPINNING", "TRACKING"]
const TILE_SIZE = 32

var telegraph_duration: int = 4 # Measured in beats
var direction: String = ""
var type: String = ""
var projectiles = []  # List of attacks
var starting_coords = []  # List of starting coordinates, measured in tiles
var speed = 1
var damage: int = 5
var count: int = 0
var turn_count: int # Spinning projectiles only

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)

func start(input_direction: String, input_type: String, input_coords: PackedVector2Array, input_turn_count: int):
	print("Projectile generated")
	set_direction(input_direction)
	set_attack_type(input_type)
	for i in range(input_coords.size()):
		var projectile_attack = generate_projectile.instantiate()
		# Keep references to projectile nodes
		projectiles.append(projectile_attack)
		# AND make sure to add them to the tree!! (as a child of this scene, IteractiveProjectile)
		add_child(projectile_attack)
		projectiles[i].start(direction, input_coords[i])
		starting_coords.append(input_coords[i])
	turn_count = input_turn_count
	$TelegraphTimer.start()
	match type:
		"STRAIGHT":
			match direction:
				"WEST":
					add_scene($Telegraph, telegraph_image_west);
				"EAST":
					add_scene($Telegraph, telegraph_image_east);
				"NORTH":
					add_scene($Telegraph, telegraph_image_north);
				"SOUTH":
					add_scene($Telegraph, telegraph_image_south);
		"EXPANDING":
				add_scene($Telegraph, telegraph_image_expanding);
		"SPINNING":
			match direction:
				"WEST":
					add_scene($Telegraph, telegraph_image_spinning_west);
				"EAST":
					add_scene($Telegraph, telegraph_image_spinning_east);
				"NORTH":
					add_scene($Telegraph, telegraph_image_spinning_north);
				"SOUTH":
					add_scene($Telegraph, telegraph_image_spinning_south);
		"TRACKING":
			add_scene($Telegraph, telegraph_image_tracking);

func start_one_coord(input_direction: String, input_type: String, input_coord: Vector2, input_turn_count: int):
	print("Projectile generated")
	set_direction(input_direction)
	set_attack_type(input_type)
	var projectile_attack = generate_projectile.instantiate()
	# Keep reference to projectile
	projectiles.append(projectile_attack)
	# AND add it to tree!!
	add_child(projectile_attack)
	projectiles[0].start(direction, input_coord)
	starting_coords.append(input_coord)
	turn_count = input_turn_count
	$TelegraphTimer.start()
	match type:
		"STRAIGHT":
			match direction:
				"WEST":
					add_scene($Telegraph, telegraph_image_west);
				"EAST":
					add_scene($Telegraph, telegraph_image_east);
				"NORTH":
					add_scene($Telegraph, telegraph_image_north);
				"SOUTH":
					add_scene($Telegraph, telegraph_image_south);
		"EXPANDING":
				add_scene($Telegraph, telegraph_image_expanding);
		"SPINNING":
			match direction:
				"WEST":
					add_scene($Telegraph, telegraph_image_spinning_west);
				"EAST":
					add_scene($Telegraph, telegraph_image_spinning_east);
				"NORTH":
					add_scene($Telegraph, telegraph_image_spinning_north);
				"SOUTH":
					add_scene($Telegraph, telegraph_image_spinning_south);
		"TRACKING":
			add_scene($Telegraph, telegraph_image_tracking);

# Called every beat.
#TODO: Make this based on beat, not time
func update(beat_num: int) -> void:
	for child in get_children():
		# Changed to remove sprites only (used to be 'not Timer')
		if child is Sprite2D:
			remove_child(child)
	match type:
		"STRAIGHT":
			for projectile in projectiles:
				projectile.move()
				projectile.add_scene(self)
		"EXPANDING":
			add_corners()
			count += 1
			for projectile in projectiles:
				projectile.move()
				projectile.add_scene(self)
		"SPINNING":
			if count >= turn_count - 1:
				match projectiles[0].direction:
					"WEST":
						for projectile in projectiles:
							projectile.direction = "NORTH"
					"SOUTH":
						for projectile in projectiles:
							projectile.direction = "WEST"
					"EAST":
						for projectile in projectiles:
							projectile.direction = "SOUTH"
					"NORTH":
						for projectile in projectiles:
							projectile.direction = "EAST"
				count = 0
			for projectile in projectiles:
				projectile.move()
				projectile.add_scene(self)
			count += 1
		"TRACKING":
			player_coords = get_node("../Player").position
			print(floor(player_coords.x / TILE_SIZE))
			print(floor(player_coords.y / TILE_SIZE))
			for projectile in projectiles:
				if floor(player_coords.y / TILE_SIZE) < projectile.coord.y:
					if floor(player_coords.x / TILE_SIZE) < projectile.coord.x:
						if projectile.coord.x - floor(player_coords.x / TILE_SIZE) < projectile.coord.y - floor(player_coords.y / TILE_SIZE):
							projectile.direction = "NORTH"
						else:
							projectile.direction = "WEST"
					else:
						if projectile.coord.x - floor(player_coords.x / TILE_SIZE) < player_coords.y - floor(player_coords.y / TILE_SIZE):
							projectile.direction = "NORTH"
						else:
							projectile.direction = "EAST"
				else:
					if floor(player_coords.x / TILE_SIZE) < projectile.coord.x:
						if floor(player_coords.x / TILE_SIZE) - projectile.coord.x < projectile.coord.y - floor(player_coords.y / TILE_SIZE):
							projectile.direction = "SOUTH"
						else:
							projectile.direction = "WEST"
					else:
						if floor(player_coords.x / TILE_SIZE) - projectile.coord.x < floor(player_coords.y / TILE_SIZE) - projectile.coord.y:
							projectile.direction = "SOUTH"
						else:
							projectile.direction = "EAST"
				projectile.move()
				projectile.add_scene(self)

# Adds courners to expanding projectiles
func add_corners():
	for coord in starting_coords:
		var to_generate: Vector2
		to_generate.x = coord.x - count
		to_generate.y = coord.y - count
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("NORTH", to_generate)
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("WEST", to_generate)
		to_generate.x -= 1
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("NORTH", to_generate)
		to_generate.x = coord.x + count
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("EAST", to_generate)
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("NORTH", to_generate)
		to_generate.y -= 1
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("EAST", to_generate)
		to_generate.y = coord.y + count
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("SOUTH", to_generate)
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("EAST", to_generate)
		to_generate.x += 1
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("SOUTH", to_generate)
		to_generate.x = coord.x - count
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("WEST", to_generate)
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("SOUTH", to_generate)
		to_generate.y += 1
		projectiles.append(generate_projectile.instantiate())
		projectiles[-1].start("WEST", to_generate)


# Allows parent nodes to set orientation of attack
func set_direction(cardinal: String):
	# Default to West on invalid input
	if cardinal not in DIRECTIONS:
		direction = "WEST"
	else:
		direction = cardinal

# Allows parent nodes to set type of attack
func set_attack_type(input: String):
	# Default to Straight on invalid input
	if input not in TYPE:
		type = "STRAIGHT"
	else:
		type = input
		
func _on_telegraph_timer_timeout():
	# Enable collision area
	for projectile in projectiles:
		projectile.enable_hitzone()
		projectile.add_scene(self)

	# Could be optimized to avoid adding more children
	$Telegraph.visible = false
	#add_scene(self)
	# Connect to beat signal rather than using UpdateTimer
	Conductor.quarter_beat.connect(update)
	
	
func add_scene(parent: Node2D, scene: PackedScene):
	for projectile in projectiles:
		var sprite = scene.instantiate()
		sprite.position.x = projectile.coord.x * TILE_SIZE + TILE_SIZE / 2
		sprite.position.y = projectile.coord.y * TILE_SIZE + TILE_SIZE / 2
		parent.add_child(sprite)	

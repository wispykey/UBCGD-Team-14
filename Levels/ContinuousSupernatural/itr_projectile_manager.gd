extends Node2D

#TODO: Add terrain collision so the projectile disappears when it hits a wall
#TODO: Implement other types of projectiles

@onready var player_coords

const DIRECTIONS = {"UP": Vector2.UP, "DOWN": Vector2.DOWN, "LEFT": Vector2.LEFT, "RIGHT": Vector2.RIGHT}
const TYPE = ["STRAIGHT", "EXPANDING", "SPINNING", "TRACKING"]
const TILE_SIZE = 32

# Linked nodes
@export var telegraph_image_left: PackedScene
@export var telegraph_image_right: PackedScene
@export var telegraph_image_up: PackedScene
@export var telegraph_image_down: PackedScene
@export var telegraph_image_expanding: PackedScene
@export var telegraph_image_spinning_left: PackedScene
@export var telegraph_image_spinning_right: PackedScene
@export var telegraph_image_spinning_up: PackedScene
@export var telegraph_image_spinning_down: PackedScene
#@export var telegraph_image_tracking: PackedScene
@export var projectile_instance: PackedScene

var telegraph_duration: int = 4 # Measured in beats
var direction: String = ""
var type: String = ""
var projectiles = []  # List of attacks
var starting_coords = []  # List of starting coordinates, measured in tiles
var speed = 1
var damage: int = 1
var count: int = 0
var turn_count: int # Spinning projectiles only

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)

func start(input_direction: String, input_type: String, input_coords: PackedVector2Array, input_turn_count: int):
	set_direction(input_direction)
	set_attack_type(input_type)
	
	for coord in input_coords:
		var projectile = projectile_instance.instantiate()
		projectiles.append(projectile)
		add_child(projectile)
		projectile.start(direction, coord)
		starting_coords.append(coord)
	turn_count = input_turn_count
	$TelegraphTimer.start()
	add_telegraph_image()

func add_telegraph_image():
	match type:
		"STRAIGHT":
			match direction:
				"LEFT":
					add_scene($Telegraph, telegraph_image_left)
				"RIGHT":
					add_scene($Telegraph, telegraph_image_right)
				"UP":
					add_scene($Telegraph, telegraph_image_up)
				"DOWN":
					add_scene($Telegraph, telegraph_image_down)
		"EXPANDING":
			add_scene($Telegraph, telegraph_image_expanding)
		"SPINNING":
			match direction:
				"LEFT":
					add_scene($Telegraph, telegraph_image_spinning_left)
				"RIGHT":
					add_scene($Telegraph, telegraph_image_spinning_right)
				"UP":
					add_scene($Telegraph, telegraph_image_spinning_up)
				"DOWN":
					add_scene($Telegraph, telegraph_image_spinning_down)
		#"TRACKING":
			#add_scene($Telegraph, telegraph_image_tracking)

# Called every beat.
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
		"SPINNING": # TODO: Needs a way to terminate! Currently spins forever
			if count >= turn_count - 1:
				match projectiles[0].direction:
					"LEFT":
						for projectile in projectiles:
							projectile.direction = "UP"
					"DOWN":
						for projectile in projectiles:
							projectile.direction = "LEFT"
					"RIGHT":
						for projectile in projectiles:
							projectile.direction = "DOWN"
					"UP":
						for projectile in projectiles:
							projectile.direction = "RIGHT"
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
							projectile.direction = "UP"
						else:
							projectile.direction = "LEFT"
					else:
						if projectile.coord.x - floor(player_coords.x / TILE_SIZE) < player_coords.y - floor(player_coords.y / TILE_SIZE):
							projectile.direction = "UP"
						else:
							projectile.direction = "RIGHT"
				else:
					if floor(player_coords.x / TILE_SIZE) < projectile.coord.x:
						if floor(player_coords.x / TILE_SIZE) - projectile.coord.x < projectile.coord.y - floor(player_coords.y / TILE_SIZE):
							projectile.direction = "DOWN"
						else:
							projectile.direction = "LEFT"
					else:
						if floor(player_coords.x / TILE_SIZE) - projectile.coord.x < floor(player_coords.y / TILE_SIZE) - projectile.coord.y:
							projectile.direction = "DOWN"
						else:
							projectile.direction = "RIGHT"
				projectile.move()
				projectile.add_scene(self)
	for projectile in projectiles:
		if projectile.out_of_bound():
			projectiles.erase(projectile)
			projectile.queue_free()

# Adds corners to expanding projectiles
func add_corners():
	for coord in starting_coords:
		var to_generate: Vector2
		to_generate.x = coord.x - count
		to_generate.y = coord.y - count
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("UP", to_generate)
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("LEFT", to_generate)
		to_generate.x -= 1
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("UP", to_generate)
		to_generate.x = coord.x + count
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("RIGHT", to_generate)
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("UP", to_generate)
		to_generate.y -= 1
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("RIGHT", to_generate)
		to_generate.y = coord.y + count
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("DOWN", to_generate)
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("RIGHT", to_generate)
		to_generate.x += 1
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("DOWN", to_generate)
		to_generate.x = coord.x - count
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("LEFT", to_generate)
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("DOWN", to_generate)
		to_generate.y += 1
		projectiles.append(projectile_instance.instantiate())
		projectiles[-1].start("LEFT", to_generate)

# Allows parent nodes to set orientation of attack
func set_direction(cardinal: String):
	# Default to LEFT on invalid input
	if cardinal not in DIRECTIONS:
		direction = "LEFT"
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
	Conductor.quarter_beat.connect(update)

func add_scene(parent: Node2D, scene: PackedScene):
	for projectile in projectiles:
		var sprite = scene.instantiate()
		sprite.position.x = projectile.coord.x * TILE_SIZE + TILE_SIZE / 2
		sprite.position.y = projectile.coord.y * TILE_SIZE + TILE_SIZE / 2
		parent.add_child(sprite)

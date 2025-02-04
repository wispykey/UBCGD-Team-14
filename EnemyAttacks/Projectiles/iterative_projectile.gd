extends Node2D

#TODO: Add terrian collision so the projectile disappers when it hit a wall
#      (Maybe make a variable that would make it pass through the wall instead at some point?)
#TODO: Implement other types of projectiles
#TODO: Erase sprites after the projectile moves

@export var telegraph_image_west: PackedScene
@export var telegraph_image_east: PackedScene
@export var telegraph_image_north: PackedScene
@export var telegraph_image_south: PackedScene
@export var generate_projectile: PackedScene

const DIRECTIONS = ["WEST", "EAST", "NORTH", "SOUTH"]
const TYPE = ["STRAIGHT", "EXPANDING", "SPINNING", "TRACKING"]
const TILE_SIZE = 32

var telegraph_duration: int  = 4 # Measured in beats
var direction: String = ""
var type: String = ""
var projectiles = []  # List of attacks
var speed = 1
var damage: int = 5
var count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	$UpdateTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$UpdateTimer.timeout.connect(_on_update_timer_timeout)

func start(input_direction: String, input_type: String, input_coords: PackedVector2Array):
	print("Projectile generated")
	set_direction(input_direction)
	set_attack_type(input_type)
	match type:
		"STRAIGHT":
			for i in range(input_coords.size()):
				projectiles.append(generate_projectile.instantiate())
				projectiles[i].start(direction, input_coords[i])
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

func start_one_coord(input_direction: String, input_type: String, input_coord: Vector2):
	print("Projectile generated")
	set_direction(input_direction)
	set_attack_type(input_type)
	match type:
		"STRAIGHT":
			projectiles.append(generate_projectile.instantiate())
			projectiles[0].start(direction, input_coord)
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
				

# Called every beat.
#TODO: Make this based on beat, not time
func update() -> void:
	for child in get_children():
		if child is not Timer:
			remove_child(child)
	if type == "STRAIGHT":
		for projectile in projectiles:
			projectile.move()
			projectile.add_scene(self)
#	add_scene(self)
	$UpdateTimer.start()

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
	$UpdateTimer.start()
	
func _on_update_timer_timeout():
	update()
	
func add_scene(parent: Node2D, scene: PackedScene):
	for projectile in projectiles:
		var sprite = scene.instantiate()
		sprite.position.x = projectile.coord.x * TILE_SIZE + TILE_SIZE / 2
		sprite.position.y = projectile.coord.y * TILE_SIZE + TILE_SIZE / 2
		parent.add_child(sprite)	

extends Area2D

@export var attack_image: PackedScene

const DIRECTIONS = ["WEST", "EAST", "NORTH", "SOUTH"]
const TILE_SIZE = 32

var direction: String = ""
var coord: Vector2 # Measured in tiles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable collisions during telegraph
	$HitZone.monitorable = false
	$HitZone.monitoring = false


func start(input_direction: String, input_coord: Vector2):
	print("Projectile generated")
	direction = input_direction
	coord = input_coord

#Handles moving in the given direction
func move() -> void:
	match direction:
		"WEST":
			coord.x -= 1
		"EAST":
			coord.x += 1
		"NORTH":
			coord.y -= 1
		"SOUTH":
			coord.y += 1
	generate_collision_area()
	
func enable_hitzone():
	$HitZone.monitoring = true
	$HitZone.monitorable = true
	generate_collision_area()

func add_scene(parent: Node2D):
	var sprite = attack_image.instantiate()
	sprite.position.x = coord.x * TILE_SIZE + TILE_SIZE / 2
	sprite.position.y = coord.y * TILE_SIZE + TILE_SIZE / 2
	parent.add_child(sprite)

# Hitzone is regenerated when the projectile moves
func generate_collision_area():
	for shape in $HitZone.get_children():
		$HitZone.remove_child(shape);
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	var dimension: Vector2
	dimension.x = TILE_SIZE
	dimension.y = TILE_SIZE
	rect_shape.size = dimension
	collision_shape.set_shape(rect_shape)
	$HitZone.add_child(collision_shape)
	$HitZone.position.x = coord.x * TILE_SIZE
	$HitZone.position.y = coord.y * TILE_SIZE

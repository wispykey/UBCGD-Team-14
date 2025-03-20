extends Area2D

const DIRECTIONS = {"UP": Vector2.UP, "DOWN": Vector2.DOWN, "LEFT": Vector2.LEFT, "RIGHT": Vector2.RIGHT}
const TILE_SIZE = 32

@export var attack_image: PackedScene

var direction: String = ""
var coord: Vector2 # Measured in tiles
var collision_shape: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable collisions during telegraph
	$HitZone.monitorable = false
	$HitZone.monitoring = false
	
	collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(TILE_SIZE, TILE_SIZE)
	collision_shape.shape = rect_shape
	$HitZone.add_child(collision_shape)


func start(input_direction: String, input_coord: Vector2):
	direction = input_direction
	coord = input_coord

#Handles moving in the given direction
func move() -> void:
	var end_loc = coord + DIRECTIONS[direction]
	coord = end_loc
	update_collision_area()

func out_of_bound():
	return coord.x > 20 or coord.x < 0 or coord.y > 14 or coord.y < 0

func enable_hitzone():
	$HitZone.monitoring = true
	$HitZone.monitorable = true
	update_collision_area()

# Hitzone is regenerated when the projectile moves
func update_collision_area():	
	$HitZone.position = coord * TILE_SIZE + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)


func add_scene(parent: Node2D):
	var sprite = attack_image.instantiate()
	sprite.position.x = coord.x * TILE_SIZE + TILE_SIZE / 2
	sprite.position.y = coord.y * TILE_SIZE + TILE_SIZE / 2
	parent.add_child(sprite)

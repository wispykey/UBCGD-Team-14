extends Node2D

@export var telegraph_image: PackedScene
@export var attack_image: PackedScene

const TILE_SIZE = 32

var telegraph_duration: int  = 4 # Measured in beats
# Width x Height of the attack, measured in tiles
@export var dimensions: Vector2i # Measured in tiles
var coords: Vector2 # Measured in tiles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	# Disable collisions during telegraph
	$HitZone.monitorable = false
	$HitZone.monitoring = false
	
	$DespawnTimer.wait_time = 4


func start():
	normalize_position()
	generate_collision_area()
	
	$TelegraphTimer.start()
	add_scene_on_every_tile($Telegraph, telegraph_image)

func set_dimensions(new_dimensions: Vector2i):
	dimensions = new_dimensions

func set_duration(beats: int):
	$DespawnTimer.wait_time = beats

func add_scene_on_every_tile(parent: Node2D, scene: PackedScene):
	# For a 3x3, offset should be -1,-1; f
	var offset_in_tiles = -Vector2(floor(dimensions.x/2), floor(dimensions.y/2))
	# TODO: Account for non-square dimensions
	
	for i in dimensions.x:
		for j in dimensions.y:
			var telegraph = scene.instantiate()
			telegraph.position.x = TILE_SIZE*(i + offset_in_tiles.x)
			telegraph.position.y = TILE_SIZE*(j + offset_in_tiles.y)
			parent.add_child(telegraph)	


func normalize_position():
	var viewport = get_viewport_rect()
	var center = viewport.get_center()
	
	# Originate from center of arena by default
	if position == Vector2.ZERO:
		position.x = center.x
		position.y = center.y
	
	# Get the position of top-left corner of the bounding tile
	var x = int(position.x) - int(position.x) % TILE_SIZE
	var y = int(position.y) - int(position.y) % TILE_SIZE
	
	# Store grid-based coordinates
	coords.x = x / TILE_SIZE
	coords.y = y / TILE_SIZE
	
# HitZone is intentionally missing CollisionShape. Added here.
func generate_collision_area():
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = dimensions * TILE_SIZE
	collision_shape.set_shape(rect_shape)
	$HitZone.add_child(collision_shape)
	
	if dimensions.x % 2 == 0:
		$HitZone.position.x -= TILE_SIZE/2.0
	if dimensions.y % 2 == 0:
		$HitZone.position.y -= TILE_SIZE/2.0
	
	
func _on_telegraph_timer_timeout():
	# Enable collision area
	$HitZone.monitoring = true
	$HitZone.monitorable = true

	# Could be optimized to avoid adding more children
	$Telegraph.visible = false
	add_scene_on_every_tile(self, attack_image)
	$DespawnTimer.start()
	
	# Play SFX
	$SpawnSFX.play()
	$ContinuousSFX.play()
			
			
func _on_despawn_timer_timeout():
	call_deferred("queue_free")

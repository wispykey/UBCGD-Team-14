extends Node2D

@export var telegraph_duration: int # Measured in beats
@export var telegraph_image: PackedScene
@export var attack_image: PackedScene

const TILE_SIZE = 32

# Width x Height of the attack, measured in tiles
var dimensions: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	# Start manually instead of auto-start to change wait_time above
	$TelegraphTimer.start()
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	
	
	# Originate from center of arena, if no position is inherited
	if position == Vector2.ZERO:
		position.x = get_viewport_rect().get_center().x
	position.y = get_viewport_rect().get_center().y
	
	# Dynamically compute dimensions based on origin position
	dimensions.x = position.x / TILE_SIZE
	dimensions.y = get_viewport_rect().size.y / TILE_SIZE

	# Create collision area + shape, based on dimensions
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = dimensions * TILE_SIZE
	collision_shape.set_shape(rect_shape)
	$HitZone.add_child(collision_shape)
	$HitZone.position = dimensions * TILE_SIZE / 2
	# Disable collisions until telegraph ends
	$HitZone.monitorable = false
	$HitZone.monitoring = false
	
	# Add alert sign telegraph for every tile covered
	for i in dimensions.x:
		for j in dimensions.y:
			var telegraph = telegraph_image.instantiate()
			telegraph.position.x = -1 * TILE_SIZE*(i + 0.5)
			telegraph.position.y = -1 * TILE_SIZE*(j - floor(dimensions.y/2))
			$Telegraph.add_child(telegraph)


func _on_telegraph_timer_timeout():
	# Enable collision area
	$HitZone.monitoring = true
	$HitZone.monitorable = true

	# Could be optimized to avoid adding more children
	$Telegraph.visible = false
	for i in dimensions.x:
		for j in dimensions.y:
			var attack = attack_image.instantiate()
			attack.position.x = -1 * TILE_SIZE*(i + 0.5)
			attack.position.y = -1 * TILE_SIZE*(j - floor(dimensions.y/2))
			add_child(attack)
	$DespawnTimer.start()
			
			
func _on_despawn_timer_timeout():
	call_deferred("queue_free")
	
	

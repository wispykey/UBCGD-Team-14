extends Node2D

@export var coords: Vector2
@export var telegraph_duration: int # Measured in beats
@export var dimensions: Vector2
@export var telegraph_image: PackedScene
@export var attack_image: PackedScene

const TILE_SIZE = 32

var damage: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	# Start manually instead of auto-start to change wait_time above
	$TelegraphTimer.start()
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	$HitZone.body_entered.connect(_on_hitzone_body_entered)

	# Create collision area + shape, based on dimensions
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = dimensions * TILE_SIZE
	collision_shape.set_shape(rect_shape)
	$HitZone.add_child(collision_shape)
	$HitZone.position = dimensions * TILE_SIZE / 2
	# Disable collisions until telegraph ends
	$HitZone.monitoring = false
	
	# Add alert sign telegraph for every tile covered
	for i in dimensions.x:
		for j in dimensions.y:
			var telegraph = telegraph_image.instantiate()
			telegraph.position.x = position.x + i * TILE_SIZE + TILE_SIZE/2
			telegraph.position.y = position.y + j * TILE_SIZE + TILE_SIZE/2
			$Telegraph.add_child(telegraph)


func _on_telegraph_timer_timeout():
	# Enable collision area
	$HitZone.monitoring = true

	# Could be optimized to avoid adding more children
	$Telegraph.visible = false
	for i in dimensions.x:
		for j in dimensions.y:
			var attack = attack_image.instantiate()
			attack.position.x = position.x + i * TILE_SIZE + TILE_SIZE/2
			attack.position.y = position.y + j * TILE_SIZE + TILE_SIZE/2
			add_child(attack)
	$DespawnTimer.start()
			
			
func _on_despawn_timer_timeout():
	call_deferred("queue_free")


func _on_hitzone_body_entered(body: Node2D):
	GameState.life -= damage
	print("Damage taken")
	
	

extends Node2D

@export var coords: Vector2
@export var telegraph_duration: int # Measured in beats
@export var dimensions: Vector2
@export var telegraph_image: PackedScene
@export var attack_image: PackedScene

const TILE_SIZE = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	# Start manually instead of auto-start to change wait_time above
	$TelegraphTimer.start()
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)

	# TODO: Compute parameters dynamically. Currently it is always West half
	# Compute the dimensions of the cleave zone, in tiles
	# Find the center point of the zone, in pixels
	# Scale and center the collision area
	
	for i in dimensions.x:
		for j in dimensions.y:
			var telegraph = telegraph_image.instantiate()
			telegraph.position.x = position.x + i * TILE_SIZE + TILE_SIZE/2
			telegraph.position.y = position.y + j * TILE_SIZE + TILE_SIZE/2
			$Telegraph.add_child(telegraph)


func _on_telegraph_timer_timeout():
	# TODO: Enable collision area(s)

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

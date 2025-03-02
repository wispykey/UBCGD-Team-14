extends Node2D

@export var telegraph_duration: int # Measured in beats

const TILE_SIZE = 32

@export var ghost: PackedScene
@export var alert_sign: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	$TelegraphTimer.start()
	
	var telegraph = alert_sign.instantiate()
	$Telegraph.add_child(telegraph)
	

func _on_telegraph_timer_timeout():
	$Telegraph.queue_free()
	spawn_ghost()
			

func spawn_ghost():
	var enemy = ghost.instantiate()
	add_child(enemy)
	
	# Have the ghost automatically despawn after a while
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	$DespawnTimer.wait_time = 5 * Conductor.seconds_per_quarter_note
	$DespawnTimer.start()

			
func _on_despawn_timer_timeout():
	queue_free()
	
	

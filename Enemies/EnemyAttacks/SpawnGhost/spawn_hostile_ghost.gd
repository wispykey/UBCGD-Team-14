extends Node2D

@export var telegraph_duration: int = 4 # Measured in beats

const TILE_SIZE = 32

@export var ghost: PackedScene
@export var green_flame: PackedScene

var spawned: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TelegraphTimer.wait_time = telegraph_duration * Conductor.seconds_per_quarter_note
	$TelegraphTimer.timeout.connect(_on_telegraph_timer_timeout)
	$TelegraphTimer.start()
	
	var telegraph = green_flame.instantiate()
	$Telegraph.add_child(telegraph)

func _process(delta: float) -> void:
	var progress = 1 - $TelegraphTimer.time_left / $TelegraphTimer.wait_time
	var proportion_at_max_val = 0.3 # Reach max value sooner for better readability
	progress = clamp(progress + proportion_at_max_val, 0.0, 1.0)
	
	if not spawned:
		$Telegraph.modulate.a = lerp(0.4, 1.0, 1 - progress)

func _on_telegraph_timer_timeout():
	$Telegraph.queue_free()
	spawn_ghost()
	spawned = true
			

func spawn_ghost():
	var enemy = ghost.instantiate()
	add_child(enemy)
	
	# Have the ghost automatically despawn after a while
	$DespawnTimer.timeout.connect(_on_despawn_timer_timeout)
	$DespawnTimer.wait_time = 5 * Conductor.seconds_per_quarter_note
	$DespawnTimer.start()

			
func _on_despawn_timer_timeout():
	queue_free()
	
	

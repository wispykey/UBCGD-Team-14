extends Area2D
class_name SpinningContinuousProjectile

@onready var sprite: Sprite2D = $Sprite2D

@export var num_projectiles: int = 8
@export var follow_type: int = 1 # 1 for path, 0 for player, 2 for circle
var current_offset: float = 0.0
var angle_step: float = 2 * PI / num_projectiles
var current_angle: float = 0.0
var center_position: Vector2
var distance: float = 0.0

var speed = 100
var direction = Vector2.ZERO
var window_dimensions
var damage: int = 2

func _ready():
	window_dimensions =  GameState.control_port.size
	
	set_physics_process(true)
	$AnimationPlayer.play("rotate_360")
	$AnimationPlayer.speed_scale = (1 / Conductor.seconds_per_quarter_note )/2

func _physics_process(delta):
	
	match follow_type:
		0:
			position += direction * speed * delta
	
	check_bounds()


func check_bounds():
	if position.x > window_dimensions.x or position.y > window_dimensions.y or position.x < 0 or position.y < 0:
		queue_free()

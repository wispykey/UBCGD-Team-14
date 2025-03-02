extends Area2D
class_name CProjectile

@onready var path_2d: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var sprite: Sprite2D = $Path2D/PathFollow2D/Sprite2D

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
var damage: int = 5

func _ready():
	window_dimensions =  get_viewport_rect().size
	
	if follow_type == 1:
		sprite.modulate = Color(0, 0, 1)
		if path_follow:
			path_follow.progress = current_offset  # Initialize offset if path_follow is valid
		else:
			print("PathFollow2D not found!")
	elif follow_type == 2:
		sprite.modulate = Color(0, 1, 0)
		center_position = position
		distance = 0
	set_physics_process(true)

func _physics_process(delta):
	
	match follow_type:
		0:
			position += direction * speed * delta
		1:
			current_offset += speed * delta / path_2d.curve.get_baked_length()
			current_offset = clamp(current_offset, 0.0, 1.0)
			
			if current_offset >= 1.0:
				queue_free()
				print("Curvy finished path!")
			else:
				if path_follow:
					path_follow.progress_ratio = current_offset  # Update offset on PathFollow2D
				else:
					print("PathFollow2D is null!")
		2:
			position += direction * speed * delta
	
	check_bounds()


func check_bounds():
	if position.x > window_dimensions.x or position.y > window_dimensions.y or position.x < 0 or position.y < 0:
		queue_free()

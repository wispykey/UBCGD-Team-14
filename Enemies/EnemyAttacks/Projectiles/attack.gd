extends AnimatedSprite2D

var finished: bool = false
@onready var hit_zone := $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	# On first time finishing, plays animation backwards
	if !finished:
		speed_scale = 1.8
		play_backwards()
		hit_zone.set_deferred("monitorable", false)
	else:
		# On second time finishing, deletes itself
		queue_free()
	finished = true
	
	

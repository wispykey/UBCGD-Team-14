extends AnimatedSprite2D

@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_scale = 1 / Conductor.seconds_per_quarter_note 
	anim.speed_scale = 1 / Conductor.seconds_per_quarter_note

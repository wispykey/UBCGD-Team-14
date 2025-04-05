extends AnimatedSprite2D

@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offset = Vector2(40, -12)
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_scale = 1 / Conductor.seconds_per_quarter_note 
	anim.speed_scale = 1 / Conductor.seconds_per_quarter_note
	global_position = %FantasyBoss.global_position

func _on_animation_finished(anim_name: String):
	$AnimationPlayer.play("hover")
	print(anim_name)
	if anim_name == "call_lightning":
		$AnimationPlayer.play("hover")
		print("played")

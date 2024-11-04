extends CharacterBody2D

@export var SPEED = 100

var spawnPoint : Vector2
var spawnRot : float

	
func _physics_process(delta):
	velocity = Vector2(0, SPEED)
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") or body.is_in_group("Projectile"):
		print("HIT!")
		queue_free()

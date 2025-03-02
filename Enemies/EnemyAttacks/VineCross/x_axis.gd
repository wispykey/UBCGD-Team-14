extends Node2D

@onready var coll_shape := $XHitZone/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_collision_region():
	var x = $Right/Head.position.x
	var size_x = 32 + x*2
	coll_shape.shape.set_size(Vector2(size_x, 32))

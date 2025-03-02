extends Node2D

@onready var coll_shape := $YHitZone/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_collision_region():
	var y = $Down/Head.position.y
	var size_y = 32 + y*2
	coll_shape.shape.set_size(Vector2(32, size_y))

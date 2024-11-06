extends Polygon2D

@onready var polygon_2d = $Polygon2D
@onready var collision = $CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision.polygon = polygon_2d.polygon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

@onready var tile = $TileMapLayer
@onready var polygon2d = $Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func break_wall() -> void:
		visible = false
		tile.collision_enabled = false

func _on_body_entered(body: Node2D) -> void:
	if body.name.match("WallBreaker"):
		break_wall()

extends Area2D

@onready var polygon2d = $Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		polygon2d.set_color(Color(0,0,0,1)) # Replace with function body.



func _on_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		polygon2d.set_color(Color(255,255,255,1)) # Replace with function body.

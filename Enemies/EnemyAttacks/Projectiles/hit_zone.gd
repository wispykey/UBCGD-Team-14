extends Area2D

var damage: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	call_deferred("set_monitorable", false)

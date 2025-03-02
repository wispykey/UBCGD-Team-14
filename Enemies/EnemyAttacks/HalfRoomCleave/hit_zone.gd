extends Area2D

var damage: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	print("LeftFireCleave: Detected player")
	call_deferred("set_monitorable", false)

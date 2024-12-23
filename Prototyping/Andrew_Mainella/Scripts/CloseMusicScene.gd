extends Node

func _on_pressed() -> void:
	self.get_parent().queue_free()

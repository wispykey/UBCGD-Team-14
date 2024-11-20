extends Node
#This is the state others will inherit
class_name MainState

signal selected_song_signal(new_value)

var selected_song = "Seven Nation Army"

# TODO remove this coode
# This is to remove the conductor at the start for the prototype
func _ready() -> void:
	var conductor = self.get_tree().root.get_node("Conductor")
	conductor.queue_free()
	

@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Song Block", "Node2D", preload("res://addons/song_block/song_block.gd"), preload("res://addons/song_block/9448086.png"))


func _exit_tree() -> void:
	remove_custom_type("Song Block")

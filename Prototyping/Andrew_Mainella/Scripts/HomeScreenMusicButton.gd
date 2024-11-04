extends Node

var in_area = false

@onready var main = self.get_tree().root.get_node("MainScreen")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var selected_song = main.selected_song
	self.get_parent().get_node("Panel").get_node("Song_Text").text = "[center]" + selected_song
	main.connect("selected_song_signal", _handel_selection_change)

func _handel_selection_change(val: String) -> void:
		self.get_parent().get_node("Panel").get_node("Song_Text").text = "[center]" + val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	in_area = true

func _on_mouse_exited() -> void:
	in_area = false
	
func _input(event: InputEvent) -> void:
	if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and in_area):
		var music_scene = load("res://Prototyping/Andrew_Mainella/Music_Picker.tscn")
		var child = music_scene.instantiate()
		self.get_tree().root.get_node("MainScreen").get_node("HomeScreen").add_child(child)

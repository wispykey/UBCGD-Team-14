extends Node

var in_area = false
var selected = false

@onready var main = self.get_tree().root.get_node("MainScreen")
@onready var title = self.get_parent().title

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if main.selected_song == title:
		selected = true
		load_selected()
	main.connect("selected_song_signal", _handel_selection_change)


func _handel_selection_change(val: String) -> void:
	if val == title:
		selected = true
		load_selected()
	else:
		selected = false
		load_normal()

func load_normal():
	if self.get_child_count() >= 1:
		var panel: Panel = self.get_child(0)
		panel.add_theme_stylebox_override("panel", load("res://addons/song_block/SongStyleBox.tres"))

func load_selected():
	if self.get_child_count() >= 1:
		var panel: Panel = self.get_child(0)
		panel.add_theme_stylebox_override("panel", load("res://addons/song_block/SongStyleBoxSelected.tres"))

func load_highlight():
	if self.get_child_count() >= 1:
		var panel: Panel = self.get_child(0)
		panel.add_theme_stylebox_override("panel", load("res://addons/song_block/SongStyleBoxHighlight.tres"))

func _on_mouse_entered() -> void:
	in_area = true
	load_highlight()


func _on_mouse_exited() -> void:
	in_area = false
	if selected:
		load_selected()
	else:
		load_normal()

func _input(event: InputEvent) -> void:
	if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and in_area):
		main.emit_signal("selected_song_signal", title)
		main.selected_song = title

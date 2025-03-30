extends Control

var levels = ["Spookesville", "Spellville"]
var current_index = 0
var level_map = {
	"Spookesville": {	"scene": "res://Levels/Supernatural.tscn",
						"image": preload("res://Assets/LevelSelect/PortalImages/grave_background_circular.png"),
						"info": "A mist-shrouded realm where flickering lanterns cast eerie glows over crumbling mausoleums. Once a haven for harmonious ghostly existence, the land is now gripped by turmoil as a vengeful spirit rises, threatening to shatter the delicate peace",
						"preview": preload("res://Assets/LevelSelect/Previews/supernatural_preview1.png")
						},
	"Spellville": { 	"scene": "res://Levels/Fantasy.tscn",
						"image": preload("res://Assets/LevelSelect/PortalImages/magic_background_circular.png"),
						"info": "A vibrant fantasy town where magic weaves through everyday life, from glowing cobblestone streets to floating marketplaces. Unbeknownst to its residents, a rogue magic now threatens to unravel its harmony.",
						"preview": preload("res://Assets/LevelSelect/Previews/fantasy_preview1.png")
						},
}

#@onready var label = $VBoxContainer/LevelDisplayContainer/TextureRect/SelectionLabel
@onready var label = $VBoxContainer/ButtonContainer/HBoxContainer/SelectionLabel
@onready var texture_rect = $VBoxContainer/LevelDisplayContainer/TextureRect
@onready var back_button = $VBoxContainer/ButtonContainer/HBoxContainer/Back
@onready var forward_button = $VBoxContainer/ButtonContainer/HBoxContainer/Forward
@onready var level_select_vbox = $VBoxContainer
@onready var animations = $AnimationPlayer
@onready var main_char = $Sprite2D
@onready var side_char = $Sprite2D2

@onready var info_box = $InfoBox
@onready var enable_controls = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_process_dialogic_signal)
	Dialogic.start("intro_dialogic")
	animations.play("idle_animation")
	level_select_vbox.modulate.a = 0
	info_box.hide()
	update_label()

func update_label():
	label.text = levels[current_index]
	texture_rect.texture = level_map[levels[current_index]].image

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip_dialog") or Input.is_action_just_pressed("ui_cancel"):
		Dialogic.end_timeline()
		_process_dialogic_signal("done_dialogic")
		
func _unhandled_input(event):
	if enable_controls == true and not TransitionScreen.animation_player.is_playing():
		if event.is_action_pressed("ui_left"):
			_on_back_pressed()
		elif event.is_action_pressed("ui_right"):
			_on_forward_pressed()
			
		if Input.is_action_just_pressed("ui_accept") and info_box.visible and level_map[levels[current_index]].scene:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished

			get_tree().change_scene_to_file(level_map[levels[current_index]].scene)
			
		elif Input.is_action_just_pressed("ui_accept"):
			selectLevel()
			
		if Input.is_action_just_pressed("ui_cancel"):
			level_select_vbox.show()
			info_box.hide()
		
func selectLevel() -> void:
	SFX.play_UI_accept()
	print("Level selected: ", levels[current_index])
	showInfo()

func _on_back_pressed() -> void:
	SFX.play_UI_switch_level()
	current_index = (current_index - 1 + levels.size()) % levels.size()
	update_label()

func _on_forward_pressed() -> void:
	SFX.play_UI_switch_level()
	current_index = (current_index + 1) % levels.size()
	update_label()

func showInfo():
	level_select_vbox.hide()
	info_box.update() # update information in info box
	info_box.show()

func _process_dialogic_signal(sig: String):
	if sig == "reveal_portals":
		fade_in(level_select_vbox)
		
	if sig == "wakeup_character":
		animations.play("character_wakeup")
		await animations.animation_finished
		animations.play("idle_animation")
		
	if sig == "look_left_to_right":
		animations.play("look_left_to_right")
		await animations.animation_finished
		animations.play("idle_animation")
		
	if sig == "done_dialogic":
		level_select_vbox.modulate.a = 1
		main_char.hide()
		side_char.hide()
		enable_controls = true

func _dialogic_complete(String):
	await get_tree().create_timer(1.0).timeout
	enable_controls = true
	#print("DIALOGUE COMPLETE")

func getCurrentLevel():
	return levels[current_index]
	
func getLevelInfo():
	return level_map[levels[current_index]].info
	
func getCurrentLevelPreview():
	return level_map[levels[current_index]].preview


func _on_texture_button_pressed() -> void:
	level_select_vbox.show()
	info_box.hide()
	
func fade_in(node: CanvasItem):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.5)

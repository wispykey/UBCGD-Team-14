# citation: "Soma Animus"
extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var flame_loader = $CPUParticles2D

func _ready():
	color_rect.visible = false
	flame_loader.visible = false
	#animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		color_rect.visible = false
		flame_loader.visible = false
	
func transition():
	color_rect.visible = true
	flame_loader.visible = true
	animation_player.play("fade_to_black")

#signal transitioned
#
#func transition():
	#$AnimationPlayer.play("fade_to_black")
	#print("fading to black")
#
#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "fade_to_black":
		#print("Emit Transitioned")
		#emit_signal("transitioned")
		#$AnimationPlayer.play("fade_to_normal")
	#if anim_name == "fade_to_normal":
		#print("Finished fading")
	##pass # Replace with function body.

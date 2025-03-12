extends Node2D

# Load all sound effects here (this mattered for HTML5 build)
var fire_spawn = preload("res://Assets/SFX/Fire/Fire 6.wav")
var fire_crackling = preload("res://Assets/SFX/Fire/Fire Crackling 1.wav")
var damage_taken = preload("res://Assets/SFX/player_damage_taken.wav")

var num_fire_crackling_entities: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the Stream variable of all AudioStreamPlayer child nodes
	$FireSpawn.stream = fire_spawn
	$FireCrackling.stream = fire_crackling
	$DamageTaken.stream = damage_taken

func play_fire_spawn():
	var pitch_variation = randf_range(0.0, 0.15)
	$FireSpawn.pitch_scale = 1.0 + pitch_variation
	$FireSpawn.play()

func play_fire_crackling():
	num_fire_crackling_entities += 1
	# Restart the sound each time a new source spawns
	var pitch_variation = randf_range(0.25, 0.50)
	$FireSpawn.pitch_scale = 1.0 + pitch_variation
	$FireCrackling.play()

func stop_fire_crackling():
	# "Ref-counting" to just have a single crackling instance 
	num_fire_crackling_entities -= 1
	if num_fire_crackling_entities == 0:	
		$FireCrackling.stop()
		
func play_damage_taken():
	$DamageTaken.play()

func play_UI_accept():
	$UIAccept.play()
	
func play_UI_switch_level():
	$UISwitchLevel.play()

func play_dash_release(charges: int):
	const MAX_CHARGES = 3
	const pitch_increase = 0.2 # Increase pitch scale for smaller dashes
	$DashRelease.volume_db = 0.0 - 2.0*(MAX_CHARGES - charges)
	$DashRelease.pitch_scale = 1.0 + 0.2*(MAX_CHARGES - charges)
	$DashRelease.play()

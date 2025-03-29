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
	const pitch_increase = 0.3 # Increase pitch scale for smaller dashes
	var random_shift = randf_range(-0.1, 0.1) # Should be much less than pitch_increase
	
	const cutoffs = [0, 600, 300, 50]
	# Get hard-coded bus ("DashRelease") and effect (HighPassFilter)
	var audio := AudioServer.get_bus_effect(1, 0)
	# Higher cutoff for lower charges (i.e. more charges = more bass)
	if (audio):
		audio.set_cutoff(cutoffs[charges])
	
	$DashRelease.volume_db = 0.0 - 2.0*(MAX_CHARGES - charges)
	$DashRelease.pitch_scale = 1.0 + 0.2*(MAX_CHARGES - charges) + random_shift
	$DashRelease.play()

func play_lightning_strike():
	var random_shift = randf_range(0.0, 0.3)
	var random_version = randi_range(1, 2)
	var sfx = get_node("Lightning/LightningStrike" + str(random_version))
	sfx.pitch_scale = 1.0 + random_shift
	sfx.play()

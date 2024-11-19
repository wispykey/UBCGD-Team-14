extends Node
# Conductor handles playing music and tracking beats.

# Emitted on every quarter beat
signal quarter_beat(beat_num: int)

# Type-inferred references for IntelliSense.
@onready var music := $Music
@onready var sfx_test := $SFXTest

# Drum stick sound on each quarter-note, for debug.
@export var metronome: bool = true

# Enums cannot be floats, so define individually.
const QUARTER_NOTE: float = 1.0
const EIGHTH_NOTE: float = 0.5 

# Dictionary of music assets we are using in the game.
# Could be dynamically loaded from files - but maybe not worth the effort.
var songs: Dictionary = {
	"Test": {
		"bpm": 88, 
		"file_name": "harmonic_hustle_overworld.wav"
	},
	"Fantasy1": {
		"bpm": 180, 
		"file_name": "fantasy_1.mp3",
	},
	"Fantasy2": {
		"bpm": 180,
		"file_name": "fantasy_2.mp3",
	},
	"Supernatural1": {
		"bpm": 140,
		"file_name": "supernatural_1.wav"
	},
	"Supernatural2": {
		"bpm": 104,
		"file_name": "supernatural_2.wav"
	}  
}

# Duration of a quarter note, in seconds.
var seconds_per_quarter_note: float
# How often to send signals.
var signal_step_interval: float 
# 1-indexed. A value of +1.0 means one quarter note has passed.
var num_beats_passed: float
# 1-indexed. In a measure of 4/4, cycles between 1-2-3-4.
var beat_number: int

# TODO: Improve step consistency for interpolation
var current_time_in_secs: float

func _ready() -> void:
	set_music("Test")
	current_time_in_secs = 0.0


func _process(delta: float) -> void:
	update_beat_info()
	print(current_time_in_secs)
	
# Updates number of beats 
func update_beat_info() -> void:
	var playback_time_in_secs = compute_playback_time()
	# Update variable to be used for interpolation
	current_time_in_secs = playback_time_in_secs
	
	# Check if one beat's worth of time has passed
	var beats_passed_in_secs: float = num_beats_passed * seconds_per_quarter_note
	if playback_time_in_secs > beats_passed_in_secs:
		num_beats_passed += signal_step_interval
		beat_number = int(num_beats_passed - 1) % 4 + 1
		# Emit signal for game events that happen on the quarter-note pulse
		quarter_beat.emit(beat_number)
		# Quarter note pulse, for debug
		if metronome: sfx_test.play()
		# Debug output.
		var inaccuracy_in_ms = (playback_time_in_secs - beats_passed_in_secs) * 1000
		print("Beat ", beat_number)
		print("Inaccuracy: %1.2f" % inaccuracy_in_ms, " ms\n")
		

# Sets the current music to a song with name, if available
func set_music(name: String) -> void:
	music.stop()
	num_beats_passed = 0.0
	# Quarter notes only, for now.
	signal_step_interval = QUARTER_NOTE
	
	# Attempt to retrieve song
	if !songs.has(name):
		print("Error loading music. Could not find song called \'", name, "\'")
		return
	
	var song_to_play = songs[name]
	var file_path: String = "res://Assets/Music/" + song_to_play.file_name
	music.stream = load(file_path)
	seconds_per_quarter_note = convert_bpm_to_quarter_note_in_secs(song_to_play.bpm)
	music.play()
	print("Playing song: \"", name, "\"\n")

	
# Returns how long audio has played for, in seconds.
# Makes adjustments to improve synchronization between audio and game events.
# Adapted from: https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
func compute_playback_time() -> float:
	# Guard against errors causing music to fail
	if (!music.playing):
		return 0.0
	# Query how long the audio file has been playing for, in seconds.
	var time = $Music.get_playback_position()
	# Adjust for chunk delay. Retrieves positive values even if no music is playing.
	var audio_delta = AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	var latency: float =  AudioServer.get_output_latency()
	return max(0.0, time + audio_delta - latency)


# Converts bpm into how long a quarter lasts, in seconds
func convert_bpm_to_quarter_note_in_secs(bpm: int) -> float:
	return 60.0 / bpm

extends RichTextLabel


@onready var main = self.get_tree().root.get_node("MainScreen")

# Produces the time of the integer. Takes in a integer of the number of seconds
func _intToTime(time: int) -> String:
	if (time <= 0):
		return "00:00"
	var seconds = time % 60
	var minutes = floor(time/60)
	return "%02d:%02d" % [minutes, seconds]

var end = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	var song = Songs.new().get_song(main.selected_song)
	player.stream = song
	end = player.stream.get_length()
	self.text = _intToTime(end)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var secondsElapsed = floor(Time.get_ticks_msec()/1000)
	print(floor(end - secondsElapsed))
	self.text = _intToTime(floor(end - secondsElapsed))
	pass

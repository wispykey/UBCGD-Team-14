extends Line2D

@export var direction: Vector2
@export var player_offset: Vector2
@export var waveform_scale: float = 1.0  # Adjust to scale the ECG pattern

var direction_angles: Dictionary = {
	Vector2(1, 0): PI,
	Vector2(-1, 0): 0,
	Vector2(0, -1): PI/2,
	Vector2(0, 1): 3*PI/2
}

func _process(delta):
	if not is_visible_in_tree():
		return  # Skip processing if the node is not visible
		
	# Generate ECG waveform with a scaled width
	var rotation_angle = direction_angles.get(direction, 0)  # Default to 0 if not found
	
	var ecg_points = generate_ecg_waveform(player_offset.length())  # Scale horizontally
	for i in range(ecg_points.size()):
		ecg_points[i] *= waveform_scale  # Scale amplitude
		ecg_points[i] = ecg_points[i].rotated(rotation_angle)  # Align direction
	
	points = ecg_points

func generate_ecg_waveform(width: float) -> PackedVector2Array:
	var wave = PackedVector2Array()
	var step = width / 20.0  # Adjust for smoothness
	for i in range(21):
		var x = i * step
		var y = sin_waveform(i / 20.0) * 10.0  # Basic ECG shape with amplitude
		wave.append(Vector2(x, y))
	return wave

func sin_waveform(t: float) -> float:
	# Simulated ECG waveform (modify for more accuracy)
	if t < 0.2: return 0.2 * sin(PI * t * 5)
	elif t < 0.4: return -1.0 * sin(PI * (t - 0.2) * 10)
	elif t < 0.6: return 0.3 * sin(PI * (t - 0.4) * 5)
	return 0.0

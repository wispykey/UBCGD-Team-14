class_name Songs

func get_song(selected_song: String):
	if selected_song == "Seven Nation Army":
		return load("res://Prototyping/Andrew_Mainella/Assets/Seven_Nation_Army_Audio.mp3")
	if selected_song == "Pump It Up":
		return load("res://Prototyping/Andrew_Mainella/Assets/Pump_It_Up_Audio.mp3")
	if selected_song == "Dancing Queen":
		return load("res://Prototyping/Andrew_Mainella/Assets/Dancing_Queen_Audio.mp3")
	return load("res://Prototyping/Andrew_Mainella/Assets/Do_It_Right_Audio.mp3")

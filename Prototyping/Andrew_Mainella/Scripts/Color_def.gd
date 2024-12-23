
class_name color_def
const red = Color("#ff0000")    # 0 -> 1
const cyan = Color("#00bfff")   # 1 -> 2
const white = Color("#ffffff")  # 2 -> 3
const pink = Color("#ff00cc")   # 3 -> 4
const blue = Color("#2200ff")   # 4 -> 5
const green = Color("#00ff44")  # 5 -> 6
const yellow = Color("#fffb00") # 6 -> 1

const purple = Color("#c300ff") # For later use

# Given a number returns the index of the next color assumes index 0-5
func getNextColor(index: int):
	if index >= 6:
		return 0
	else:
		return index + 1

# Given a number returns the color with tha associated index
func getColor(index: int):
	match index:
		0:
			return red
		1:
			return cyan
		2:
			return white
		3:
			return pink
		4:
			return blue
		5:
			return green
		_:
			return yellow

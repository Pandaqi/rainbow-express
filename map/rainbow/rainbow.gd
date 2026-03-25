class_name Rainbow

# Responsible for all the different "things" you can play the game with (color, shapes, numbers, etc)
static var colors := [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.CYAN, Color.MAGENTA, Color.ORANGE, Color.TURQUOISE, Color.PURPLE]
static var color_names := ["red", "blue", "green", "yellow", "cyan", "magenta", "orange", "turquoise", "purple"]

# @TODO!
static var shape_names := []
static var number_names := []
static var letter_names := []

static func get_word_reminder_for(tp:int) -> String:
	var puzzle_mode : String = PuzzleSettings.get_value("puzzle_mode")
	if puzzle_mode == "Colors": return color_names[tp]
	if puzzle_mode == "Shapes": return shape_names[tp]
	if puzzle_mode == "Numbers": return number_names[tp]
	if puzzle_mode == "Letters": return letter_names[tp]
	return ""

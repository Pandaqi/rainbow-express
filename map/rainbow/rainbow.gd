class_name Rainbow

# Responsible for all the different "things" you can play the game with (color, shapes, numbers, etc)
static var colors := [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.CYAN, Color.MAGENTA, Color.ORANGE, Color(0.2, 0.2, 0.2), Color.PURPLE]
static var color_names := ["red", "blue", "green", "yellow", "cyan", "pink", "orange", "black", "purple"]

# @TODO: All of these have exactly 9 entries because that's the fixed number I decided to use in the code
# The letters, though, use a simple trick of adding the puzzle seed to select later indices at random
static var shape_names := ["circle", "ellipse", "square", "rectangle", "triangle", "arrow", "hexagon", "heart", "star"]
static var number_names := [1,2,3,4,5,6,7,8,9]
static var letter_names := ["letter-a", "letter-b", "letter-c", "letter-d", "letter-e", "letter-f", "letter-g", "letter-h", "letter-i", "letter-j", "letter-k", "letter-l", "letter-m", "letter-n", "letter-o", "letter-p", "letter-q", "letter-r", "letter-s", "letter-t", "letter-u", "letter-v", "letter-w", "letter-x", "letter-y", "letter-z"]

enum Mode
{
	COLORS,
	SHAPES,
	NUMBERS,
	LETTERS
}

static var alphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

static func get_random_color() -> Color:
	return colors.pick_random()

static func get_color_for_type(tp:int) -> Color:
	return colors[tp]

static func get_label_for_type(tp:int) -> String:
	if get_mode() == Mode.NUMBERS: return str(tp + 1)
	return alphabet[(tp + PuzzleFramework.puzzle_seed) % alphabet.length()]

static func get_mode() -> Mode:
	var md := str(PuzzleSettings.get_value("puzzle_mode"))
	if md == "Shapes": return Mode.SHAPES
	if md == "Numbers": return Mode.NUMBERS
	if md == "Letters": return Mode.LETTERS
	return Mode.COLORS

static func get_word_reminder_for(tp:int) -> String:
	var puzzle_mode := get_mode()
	if puzzle_mode == Mode.COLORS: return color_names[tp % color_names.size()]
	if puzzle_mode == Mode.SHAPES: return shape_names[tp % shape_names.size()]
	if puzzle_mode == Mode.NUMBERS: return str(number_names[tp % number_names.size()])
	if puzzle_mode == Mode.LETTERS: return letter_names[(tp + PuzzleFramework.puzzle_seed) % letter_names.size()]
	return ""

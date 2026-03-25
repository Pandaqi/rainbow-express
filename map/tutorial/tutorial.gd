extends Node2D
class_name Tutorial

var enabled := false
var num_turns := 0
var tween_active : Tween
@export var indicator : Node2D

func _ready() -> void:
	indicator.hide()
	enabled = PuzzleSettings.get_value("show_tutorial") and PuzzleSettings.get_difficulty_level() == PuzzleDifficulty.Difficulty.EASIEST

func highlight_move(car:Car, next_cell:Cell) -> void:
	num_turns += 1
	if tween_active: 
		PuzzleTween.force_tween_completion(tween_active)
		tween_active = null
	
	if not enabled: return
	if num_turns >= 4: return
	
	var pos := next_cell.global_position
	tween_active = PuzzleTutorial.play_pointer_tween(indicator, pos)

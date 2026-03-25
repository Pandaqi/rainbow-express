extends Node2D
class_name Tutorial

var enabled := false
var num_turns := -1
var tween_active : Tween
@export var indicator : Node2D
@export var audio_explanation : AudioStreamPlayer

func _ready() -> void:
	indicator.hide()
	enabled = PuzzleSettings.get_value("show_tutorial") and PuzzleSettings.get_difficulty_level() == PuzzleDifficulty.Difficulty.EASIEST
	PuzzleFramework.puzzle_done.connect(_on_puzzle_done)
	if PuzzleFramework.num_attempts_same_puzzle >= 2 or PuzzleFramework.num_attempts >= 3:
		enabled = false

func _on_puzzle_done(_player_won:bool) -> void:
	enabled = false
	indicator.hide()
	audio_explanation.stop()

func highlight_move(_car:Car, next_cell:Cell) -> void:
	num_turns += 1
	if tween_active: 
		PuzzleTween.force_tween_completion(tween_active)
		tween_active = null
	
	if not enabled: return
	if num_turns >= 3: return
	
	var play_audio_narration : bool = num_turns == 0 and PuzzleSettings.get_value("audio_feedback") and Rainbow.get_mode() == Rainbow.Mode.COLORS
	if play_audio_narration:
		audio_explanation.play()
	
	var pos := next_cell.global_position
	tween_active = PuzzleTutorial.play_pointer_tween(indicator, pos)

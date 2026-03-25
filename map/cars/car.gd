extends Node2D
class_name Car

@export var manager : Cars

@export var mode_switcher : PuzzleModeSwitcher
@export var base : Sprite2D
@export var overlay : Sprite2D
@export var outline : Sprite2D

@export var shadow_h : Sprite2D
@export var shadow_v : Sprite2D

@export var anim_player : AnimationPlayer
@export var particles : CarParticles

@export var audio_drive : AudioStreamPlayer2D
@export var audio_switch : AudioStreamPlayer2D
@export var audio_arrived : AudioStreamPlayer2D
@export var audio_words : AudioStreamPlayer2D

@export var feedback : Node2D
@export var feedback_anim_player : AnimationPlayer
@export var audio_error : AudioStreamPlayer2D

@export var smiley_arrived : Sprite2D
@export var arrow : Sprite2D
@export var area : Area2D

var active := false
var arrived := false
var moving := false
var type := 0

var size_inactive := Vector2(0.175, 0.175)
var size_active := Vector2(0.35, 0.35)
var tween_scaling : Tween

var index : int
var num_pickups_needed : int
var num_pickups_collected : int
var grid_pos := Vector2i(-1,-1)
var route : Array[Cell] = []
var route_connections : Array[Connection] = []

var tween_movement : Tween

signal route_changed()
signal clicked(c:Car)

func _ready() -> void:
	area.input_event.connect(_on_input_event)

func _on_input_event(_vp:Node, ev:InputEvent, _sidx:int) -> void:
	if not (ev is InputEventMouseButton or ev is InputEventScreenTouch): return
	if not ev.is_released(): return
	if not PuzzleSettings.get_difficulty_property("car_order_freeform"): return
	clicked.emit(self)

func set_data(idx:int, tp:int, np:int) -> void:
	index = idx
	type = tp
	num_pickups_needed = np
	num_pickups_collected = 0

	mode_switcher.update(type)
	
	smiley_arrived.hide()
	set_active(false)

func set_grid_position(cell:Cell) -> void:
	if (cell.data.pos - grid_pos).length() <= 0: return
	var old_cell := get_current_cell()
	
	grid_pos = cell.data.pos
	cell.data.register_car_visit(index)
	route.append(cell)
	route_changed.emit()
	
	if old_cell:
		var connection_used := old_cell.data.get_connection_to(cell.data) as Connection
		if connection_used:
			connection_used.register_car_visit(index)
			route_connections.append(connection_used)
	
	await on_position_updated()

func unset_last_grid_position() -> void:
	get_current_cell().data.forget_car_visit(index)
	route.pop_back()
	route_changed.emit()
	
	# our first move won't use a connection because we're setting initial position
	if route_connections.size() > 0:
		route_connections.back().forget_car_visit(index)
		route_connections.pop_back()
		
	# @NOTE: yes, we re-grab because the current cell changed after popping route! Don't "optimize" this!
	grid_pos = get_current_cell().data.pos
	await on_position_updated()

func get_current_cell() -> Cell:
	if route.size() <= 0: return null
	return route.back()

func is_at_start() -> bool:
	return get_current_cell().data.is_start_for == index

func is_at_destination() -> bool:
	return get_current_cell().data.is_destination_for == index

func change_pickups_collected(dp:int) -> void:
	num_pickups_collected += dp

func all_pickups_collected() -> bool:
	return num_pickups_collected >= num_pickups_needed

func convert_vec_to_frame(vec:Vector2) -> int:
	if abs(vec.x) > abs(vec.y):
		if vec.x > 0: return 0
		else: return 2
	if vec.y > 0: return 1
	return 3

func on_position_updated() -> void:
	moving = true
	
	if tween_movement: PuzzleTween.force_tween_completion(tween_movement)
	
	var target_pos := get_current_cell().global_position
	
	# look the way we're going
	var vec := (target_pos - global_position).normalized()
	var frame := convert_vec_to_frame(vec)
	base.set_frame(frame)
	overlay.set_frame(4 + frame)
	outline.set_frame(8 + frame)
	
	shadow_h.set_visible(frame == 0 or frame == 2)
	shadow_v.set_visible(frame == 1 or frame == 3)
	
	# reinforce with an arrow
	var arrow_offset := 128.0
	if frame == 1: arrow_offset = 92.0
	if frame == 3: arrow_offset = 172.0
	var arrow_pos := arrow_offset * vec
	arrow.set_position(arrow_pos)
	arrow.set_rotation(vec.angle())
	arrow.show()
	
	# more effects (such as faster bounciness when moving)
	PuzzleAudio.play_audio_nice(audio_drive)
	anim_player.speed_scale = randf_range(2.5, 3.2)
	particles.update_from_car_frame(frame)
	
	# tween us going there	
	var tw := get_tree().create_tween()
	var dur := randf_range(0.3, 0.4)
	tw.tween_property(self, "position", target_pos, dur)
	tween_movement = tw
	await tw.finished
	
	arrow.hide()
	anim_player.speed_scale = randf_range(0.9, 1.1)
	moving = false

func is_moving() -> bool:
	return moving

func play_word_reminder() -> void:
	if not PuzzleSettings.get_value("audio_words"): return
	var audio_path := Rainbow.get_word_reminder_for(type)
	if not audio_path: return
	
	# to prevent overlapping with truck switching sound
	await get_tree().create_timer(0.67).timeout
	audio_words.stream = load("res://map/rainbow/sounds/" + audio_path + ".ogg")
	audio_words.play()

func set_active(ac:bool) -> void:
	if not active and ac:
		PuzzleAudio.play_audio_nice(audio_switch)
	
	active = ac
	
	if active:
		anim_player.play("idle_car")
		play_word_reminder()
	elif arrived:
		anim_player.play("finished_car")
	else:
		anim_player.stop()
	
	particles.set_active(active)
	outline.set_visible(active)
	
	if tween_scaling: PuzzleTween.force_tween_completion(tween_scaling)
	
	var new_scale := size_active if active else size_inactive
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.1, 0.3)
	tw.tween_property(self, "scale", new_scale, dur)
	tween_scaling = tw

func arrive() -> void:
	arrived = true
	get_current_cell().data.arrive(index)
	PuzzleAudio.play_audio_nice(audio_arrived)
	smiley_arrived.show()

func depart() -> void:
	get_current_cell().data.depart(index)
	arrived = false
	smiley_arrived.hide()

func on_illegal_move(new_pos:Vector2i) -> void:
	var from_pos_real := global_position
	var new_pos_real := PuzzleVisualizer.convert_cell_pos_to_real_pos(new_pos)
	var mid_pos := 0.5 * (from_pos_real + new_pos_real)
	
	feedback.set_position(to_local(mid_pos))
	feedback_anim_player.stop()
	feedback_anim_player.play("feedback_appear")
	audio_error.play()

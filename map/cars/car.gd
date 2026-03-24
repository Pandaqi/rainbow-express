extends Node2D
class_name Car

@export var base : Sprite2D
@export var overlay : Sprite2D
@export var outline : Sprite2D

@export var shadow_h : Sprite2D
@export var shadow_v : Sprite2D

@export var anim_player : AnimationPlayer
@export var particles : CarParticles

@export var audio_drive : AudioStreamPlayer2D
@export var audio_switch : AudioStreamPlayer2D
@export var audio_arrived : AudioStreamPlayer2D # @TODO: set to progress2 or something

var active := false
var arrived := false
var moving := false

var size_inactive := Vector2(0.175, 0.175)
var size_active := Vector2(0.35, 0.35)
var tween_scaling : Tween

var index : int
var num_pickups_needed : int
var num_pickups_collected : int
var color : Color
var grid_pos := Vector2i(-1,-1)
var route : Array[Cell] = []
var route_connections : Array[Connection] = []

var tween_movement : Tween

signal route_changed()

func set_data(c:Color, idx:int, np:int) -> void:
	index = idx
	num_pickups_needed = np
	num_pickups_collected = 0
	color = c
	base.modulate = c
	particles.modulate = c
	
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
	
	# @TODO: force finish current active tween
	if tween_movement and tween_movement.is_running():
		tween_movement.stop()
	
	var target_pos := get_current_cell().global_position
	
	# look the way we're going
	var vec := (target_pos - global_position).normalized()
	var frame := convert_vec_to_frame(vec)
	base.set_frame(frame)
	overlay.set_frame(4 + frame)
	outline.set_frame(8 + frame)
	
	shadow_h.set_visible(frame == 0 or frame == 2)
	shadow_v.set_visible(frame == 1 or frame == 3)
	
	# more effects (such as faster bounciness when moving)
	audio_drive.play()
	anim_player.speed_scale = randf_range(2.5, 3.2)
	particles.update_from_car_frame(frame)
	
	# tween us going there	
	var tw := get_tree().create_tween()
	var dur := 0.5
	tw.tween_property(self, "position", target_pos, dur)
	tween_movement = tw
	await tw.finished
	
	anim_player.speed_scale = randf_range(0.9, 1.1)
	moving = false

func is_moving() -> bool:
	return moving

func set_active(ac:bool) -> void:
	if not active and ac:
		audio_switch.play()
	
	active = ac
	
	if active:
		anim_player.play("idle_car")
	else:
		anim_player.stop()
	
	particles.set_active(active)
	outline.set_visible(active)
	
	if tween_scaling and tween_scaling.is_running():
		tween_scaling.stop()
	
	var new_scale := size_active if active else size_inactive
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.1, 0.3)
	tw.tween_property(self, "scale", new_scale, dur)
	tween_scaling = tw

func arrive() -> void:
	arrived = true
	get_current_cell().data.arrive(index)
	audio_arrived.play()

func depart() -> void:
	get_current_cell().data.depart(index)
	arrived = false

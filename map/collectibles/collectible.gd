extends Node2D
class_name Collectible

var data : Connection

@export var sprite_container : Node2D
@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

@export var audio_pickup : AudioStreamPlayer2D
var tween_active : Tween

func sync_data(d:Connection) -> void:
	data = d
	d.changed.connect(refresh)
	refresh()

func refresh() -> void:
	if tween_active:
		PuzzleTween.force_tween_completion(tween_active)
		tween_active = null
	
	if not data.has_pickup():
		play_disappear_animation()
		return
	
	play_appear_animation()

func play_appear_animation() -> void:
	z_index = 0
	
	set_visible(true)
	sprite.set_frame(0)
	sprite.modulate = Cars.get_car_color(data.pickup_for)
	tween_active = PuzzleTween.play_popup_tween(sprite_container)
	await tween_active.finished
	anim_player.speed_scale = randf_range(0.8, 1.2)
	anim_player.play("collectible_float")

func play_disappear_animation() -> void:
	z_index = 256
	
	PuzzleAudio.play_audio_nice(audio_pickup)
	sprite.set_frame(1)
	sprite.modulate = Color.WHITE
	tween_active = PuzzleTween.play_popdown_tween(sprite_container)
	await tween_active.finished
	set_visible(false)

extends Node2D
class_name Collectible

var data : Connection

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

# @TODO: Set to positive1.ogg
@export var audio_pickup : AudioStreamPlayer2D

func sync_data(d:Connection) -> void:
	data = d
	d.changed.connect(refresh)
	refresh()

func refresh() -> void:
	if not data.has_pickup():
		audio_pickup.play()
		set_visible(false)
		return
	
	set_visible(true)
	sprite.modulate = Cars.get_car_color(data.pickup_for)
	anim_player.speed_scale = randf_range(0.8, 1.2)
	anim_player.play("collectible_float")

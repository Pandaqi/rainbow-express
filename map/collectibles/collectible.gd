extends Node2D
class_name Collectible

var data : Connection

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

func sync_data(d:Connection) -> void:
	data = d
	refresh()

func refresh() -> void:
	sprite.modulate = Cars.get_car_color(data.pickup_for)
	anim_player.speed_scale = randf_range(0.8, 1.2)
	anim_player.play("collectible_float")

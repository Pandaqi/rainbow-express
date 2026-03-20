extends Node2D
class_name Collectible

var data : Connection

@export var sprite : Sprite2D

func sync_data(d:Connection) -> void:
	data = d
	refresh()

func refresh() -> void:
	sprite.modulate = PuzzleVisualizer.get_truck_color(data.pickup_for)

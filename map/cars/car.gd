extends Node2D
class_name Car

@export var base : Sprite2D
@export var overlay : Sprite2D

var color : Color


func set_color(c:Color) -> void:
	color = c
	base.modulate = c

extends Node2D
class_name PuzzleModeSwitcher

@export var recolor_nodes : Array[Node2D]
@export var sprite_shape : Sprite2D
@export var label : Label

func update(car_type:int) -> void:
	label.hide()
	sprite_shape.hide()
	for sprite in recolor_nodes:
		sprite.modulate = Rainbow.get_random_color()
	
	if car_type == -1: return
	
	var mode := Rainbow.get_mode()
	
	if mode == Rainbow.Mode.COLORS:
		for sprite in recolor_nodes:
			sprite.modulate = Rainbow.get_color_for_type(car_type)
	
	if mode == Rainbow.Mode.SHAPES:
		sprite_shape.show()
		# @NOTE: just made this a one-to-one match with spritesheet
		sprite_shape.set_frame(car_type)
	
	if mode == Rainbow.Mode.NUMBERS or mode == Rainbow.Mode.LETTERS:
		label.show()
		label.set_text(Rainbow.get_label_for_type(car_type))

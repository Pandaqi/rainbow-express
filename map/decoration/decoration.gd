extends Node2D
class_name Decoration

@export var sprite_trees : Sprite2D
@export var sprite_flowers : Sprite2D

var scale_bounds_trees := Vector2(0.4, 0.6)
var scale_bounds_flowers := Vector2(0.25, 0.4)

enum Type
{
	TREE,
	FLOWER
}

func _ready() -> void:
	sprite_trees.hide()
	sprite_flowers.hide()

func set_type(tp:Type) -> void:
	if tp == Type.TREE:
		sprite_trees.show()
		sprite_trees.set_frame(randi() % sprite_trees.hframes)
		var rand_scale := randf_range(scale_bounds_trees.x, scale_bounds_trees.y)
		set_scale(rand_scale * Vector2.ONE)
	
	if tp == Type.FLOWER:
		sprite_flowers.show()
		sprite_flowers.set_frame(randi() % sprite_flowers.hframes)
		var rand_scale := randf_range(scale_bounds_flowers.x, scale_bounds_flowers.y)
		set_scale(rand_scale * Vector2.ONE)

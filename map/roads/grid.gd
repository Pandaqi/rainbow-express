extends Sprite2D
class_name GridOverlay

@export var base_scale := 128.0
@export var extra_margin := 5 # in terms of grid cells, not raw pixels
@export var line_width := 0.015

func _ready() -> void:
	set_visible(PuzzleSettings.get_value("show_grid") == true)

func set_bounds(r:Rect2) -> void:
	var new_rect := Rect2(r.position - Vector2.ONE*extra_margin*base_scale, r.size + Vector2.ONE*2*extra_margin*base_scale)
	
	material.set_shader_parameter("size", new_rect.size)
	material.set_shader_parameter("line_width", line_width)
	material.set_shader_parameter("offset", Vector2.ZERO)
	material.set_shader_parameter("grid_size", PuzzleVisualizer.cell_size)
	
	set_position(new_rect.position)
	set_scale(new_rect.size / base_scale)

extends Node2D
class_name DebugVisualizer

var vis : PuzzleVisualizer
@export var enabled := true

func visualize(v:PuzzleVisualizer) -> void:
	vis = v
	queue_redraw()

func visualize_paths_debug() -> void:
	if not OS.is_debug_build(): return
	if not enabled: return
	
	for i in range(vis.generator.car_routes.size()):
		var route = vis.generator.car_routes[i].map(func(c:PuzzleCell): return vis.convert_cell_pos_to_real_pos(c.pos))
		var color := Cars.get_car_color(i)
		draw_polyline(route, color, 4.0, true)

func _draw() -> void:
	visualize_paths_debug()

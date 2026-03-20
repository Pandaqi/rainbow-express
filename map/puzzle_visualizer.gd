extends Node2D
class_name PuzzleVisualizer

var generator : PuzzleGenerator

var cell_size := 64
@export var cell_scene : PackedScene

@export var debug_visualizer : DebugVisualizer

# @TODO: eventually we just want a Trucks/Truck object for the moving sprites that also knows this
static var truck_colors : Array[Color] = [Color.BLACK, Color.RED, Color.BLUE, Color.GREEN]
static func get_truck_color(idx:int) -> Color:
	return truck_colors[idx + 1]

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	generator.debug_print_truck_routes()
	visualize_grid()
	debug_visualizer.visualize(self)

func convert_cell_pos_to_real_pos(pos:Vector2i) -> Vector2:
	return pos * cell_size

func visualize_grid() -> void:
	for cell_data in generator.grid.get_cells():
		var cell : Cell = cell_scene.instantiate()
		cell.sync_data(cell_data)
		cell.set_position(convert_cell_pos_to_real_pos(cell_data.pos))
		add_child(cell)

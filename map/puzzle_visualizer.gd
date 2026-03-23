extends Node2D
class_name PuzzleVisualizer

var generator : PuzzleGenerator

static var cell_size := 128.0

@export var cell_scene : PackedScene
@export var map_container : Node2D

@export var cars : Cars
@export var collectibles : Collectibles

@export var debug_visualizer : DebugVisualizer

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	generator.debug_print_car_routes()
	visualize_grid()
	cars.visualize(self)
	collectibles.visualize(self)
	debug_visualizer.visualize(self)

func convert_cell_pos_to_real_pos(pos:Vector2i) -> Vector2:
	return pos * cell_size

func visualize_grid() -> void:
	# place all the cells
	for cell_data in generator.grid.get_cells():
		var cell : Cell = cell_scene.instantiate()
		cell.sync_data(cell_data)
		cell.set_position(convert_cell_pos_to_real_pos(cell_data.pos))
		map_container.add_child(cell)

extends Node2D
class_name PuzzleVisualizer

var generator : PuzzleGenerator
var commands : PuzzleCommands
var cells : Array[Cell] = []
var level_bounds : Rect2

static var cell_size := 128.0

@export var cell_scene : PackedScene
@export var map_container : Node2D
@export var grid_overlay : GridOverlay

@export var cars : Cars
@export var collectibles : Collectibles

@export var debug_visualizer : DebugVisualizer
@export var decoration_scene : PackedScene

func _ready() -> void:
	cars.finished.connect(_on_cars_finished)

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	generator.debug_print_car_routes()
	visualize_grid()
	cars.visualize(self)
	collectibles.visualize(self)
	debug_visualizer.visualize(self)
	on_visualization_done()

static func convert_cell_pos_to_real_pos(pos:Vector2i) -> Vector2:
	return pos * cell_size

func visualize_grid() -> void:
	# place all the cells
	cells = []
	var cells_empty : Array[CellData] = []
	for cell_data in generator.grid.get_cells():
		var cell : Cell = cell_scene.instantiate()
		cell.sync_data(cell_data)
		cell.set_position(convert_cell_pos_to_real_pos(cell_data.pos))
		map_container.add_child(cell)
		cells.append(cell)
		
		if cell_data.count_connections() <= 0: 
			cells_empty.append(cell.data)
	
	level_bounds = Rect2(Vector2.ZERO, generator.grid.size * cell_size)
	grid_overlay.set_bounds(level_bounds)
	# @TODO: give to PuzzleCamera
	
	visualize_decorations(cells_empty)

func visualize_decorations(cells_allowed:Array[CellData]) -> void:
	# duplicate cells within grid as decorations there look better
	cells_allowed += cells_allowed
	
	# add some extra cells around the map to fill with decorations
	var extra_margin := Vector2(2,1)
	for x in range(-extra_margin.x, generator.grid.size.x + extra_margin.x):
		for y in range(-extra_margin.y, generator.grid.size.y + extra_margin.y):
			var pos := Vector2i(x,y)
			if not generator.grid.is_out_of_bounds(pos): continue
			cells_allowed.append(CellData.new(pos))
	
	var num_trees := randi_range(20, 25)
	var num_flowers := randi_range(20, 25)
	var num_decorations := num_trees + num_flowers
	
	for i in range(num_decorations):
		var cell : CellData = cells_allowed.pick_random()
		var rand_pos := 0.5*Vector2(randf_range(-1,1), randf_range(-1,1)) * cell_size + convert_cell_pos_to_real_pos(cell.pos)
		var dec : Decoration = decoration_scene.instantiate()
		# @NOTE: we add to cars layer to make it Y-sorted with that
		cars.add_child(dec) 
		
		dec.set_type(Decoration.Type.TREE if i < num_trees else Decoration.Type.FLOWER)
		dec.set_position(rand_pos)

func get_cell_for_data(cd:CellData) -> Cell:
	for cell in cells:
		if cell.data == cd: return cell
	return null

func _input(ev:InputEvent) -> void:
	if OS.is_debug_build() and ev.is_action_released("ui_accept"):
		commands.undo_last_turn()
	
	var vec := Vector2i.ZERO
	if ev.is_action_released("ui_left"): vec = Vector2i.LEFT
	if ev.is_action_released("ui_right"): vec = Vector2i.RIGHT
	if ev.is_action_released("ui_up"): vec = Vector2i.UP
	if ev.is_action_released("ui_down"): vec = Vector2i.DOWN
	if vec.length() > 0:
		move_active_car_in_direction(vec)

func _unhandled_input(ev: InputEvent) -> void:
	var is_click : bool = ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT
	var is_touch := ev is InputEventScreenTouch
	if not (is_click or is_touch): return
	if not ev.is_released(): return
	on_mouse_input_given(ev.position)

func get_grid_direction_from(dir_raw:Vector2) -> Vector2i:
	if absf(dir_raw.x) > absf(dir_raw.y):
		if dir_raw.x > 0: return Vector2i.RIGHT
		else: return Vector2i.LEFT
	else:
		if dir_raw.y > 0: return Vector2i.DOWN
		else: return Vector2i.UP

func on_mouse_input_given(pos:Vector2) -> void:
	# figure out movement direction from input position
	var car := cars.get_active_car()
	if not car: return
	
	var pos_car := car.get_global_transform_with_canvas().origin
	var dir_raw := (pos - pos_car).normalized()
	var dir := get_grid_direction_from(dir_raw)
	
	move_active_car_in_direction(dir)

func move_active_car_in_direction(dir:Vector2i) -> void:
	if commands.is_busy(): return
	
	var car := cars.get_active_car()
	if not car: return
	
	# check if we can do that
	var from_pos := car.grid_pos
	var new_pos := car.grid_pos + dir
	if generator.grid.is_out_of_bounds(new_pos):
		print("PuzzleVisualizer | Can't move out of bounds.")
		return
	
	if not generator.connection_exists_between(from_pos, new_pos):
		print("PuzzleVisualizer | No connection exists here to travel over.")
		return
	
	if generator.overlaps_used_connection(from_pos, new_pos):
		print("PuzzleVisualizer | Can't overlap a road already traveled by car before.")
		return
	
	# apply that movement
	var new_cell := get_cell_for_data(generator.grid.get_at(new_pos))
	commands.start_new_turn()
	await commands.execute_command(CommandMove.new(car, new_cell))

func on_visualization_done() -> void:
	commands = PuzzleCommands.new()
	add_child(commands)
	# @TODO: PuzzleFramework.start_puzzle()

func _on_cars_finished() -> void:
	var no_collectibles_left := generator.all_connections.filter(func(c:Connection): return c.has_pickup()).size() <= 0
	var player_won := no_collectibles_left
	print("Game Over | Player Won? " + str(player_won))
	# @TODO: PuzzleFramework.finish_puzzle(player_won)

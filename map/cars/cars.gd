extends Node2D
class_name Cars

@export var car_scene : PackedScene

@export var route_drawer_scene : PackedScene
@export var route_drawer_container : Node2D

var cars : Array[Car] = []
var active_index := -1
var freeform_selection := false

signal changed()
signal finished()

# @NOTE: A hacky trick to randomize car types, yet allow everyone to easily acccess this
# But it's fine, the game is done now
static func get_car_type(car_index:int) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = PuzzleFramework.puzzle_seed
	var car_indices := [0,1,2,3,4,5,6,7,8]
	if not [Rainbow.Mode.NUMBERS, Rainbow.Mode.LETTERS].has(Rainbow.get_mode()):
		shuffle_seeded(car_indices, rng)
	return car_indices.find(car_index)

static func shuffle_seeded(array: Array, rng: RandomNumberGenerator) -> void:
	for i in array.size() - 2:
		var j := rng.randi_range(i, array.size() - 1)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp

func _ready() -> void:
	freeform_selection = PuzzleSettings.get_difficulty_property("car_order_freeform") == true

func visualize(vis:PuzzleVisualizer) -> void:
	var gen := vis.generator
	
	for i in range(gen.count_cars()):
		var c : Car = car_scene.instantiate()
		add_child(c)
		c.set_grid_position(vis.get_cell_for_data(gen.car_starts[i]))
		c.set_data(i, get_car_type(i), gen.car_num_pickups[i])
		c.manager = self
		cars.append(c)
		
		c.clicked.connect(_on_car_clicked)
		
		var route_drawer : RouteDrawer = route_drawer_scene.instantiate()
		route_drawer.attach_to_car(c)
		route_drawer_container.add_child(route_drawer)
	
	if not freeform_selection:
		change_active(+1)

func _on_car_clicked(car_clicked:Car) -> void:
	if not freeform_selection: return
	if car_clicked.is_at_destination(): return # already arrived
	
	var all_cars_at_start_or_dest := true
	for car in cars:
		if car.is_at_destination(): continue
		if car.is_at_start(): continue
		all_cars_at_start_or_dest = false
		break
	
	if not all_cars_at_start_or_dest: return
	
	var desired_index := cars.find(car_clicked)
	set_active(desired_index)

func on_car_arrived(_c:Car) -> void:
	if freeform_selection: 
		set_active(-1) 
		return
	change_active(+1)

func on_car_departed(c:Car) -> void:
	if freeform_selection: 
		set_active(c.index)
		return
	change_active(-1)

func is_finished() -> bool:
	return active_index >= cars.size()

func set_active(idx:int) -> void:
	change_active(idx - active_index)

func change_active(dc:int) -> void:
	var cur_active := get_active_car()
	if cur_active:
		cur_active.set_active(false)
	
	active_index += dc
	changed.emit(active_index)
	cur_active = get_active_car()
	
	if cur_active: cur_active.set_active(true)
	if is_finished(): finished.emit()

func get_active_index() -> int:
	return clampi(active_index, 0, cars.size() - 1)

func get_active_car() -> Car:
	if active_index < 0 or is_finished(): return null
	return cars[get_active_index()]

extends Node2D
class_name Cars

@export var car_scene : PackedScene

@export var route_drawer_scene : PackedScene
@export var route_drawer_container : Node2D

var cars : Array[Car] = []
var active_index := 0

signal changed()
signal finished()

static func get_car_color(idx:int) -> Color:
	return Rainbow.colors[idx]

func visualize(vis:PuzzleVisualizer) -> void:
	var gen := vis.generator
	for i in range(gen.count_cars()):
		var c : Car = car_scene.instantiate()
		add_child(c)
		c.set_grid_position(vis.get_cell_for_data(gen.car_starts[i]))
		c.set_data(get_car_color(i), i, gen.car_num_pickups[i])
		c.manager = self
		cars.append(c)
		
		var route_drawer : RouteDrawer = route_drawer_scene.instantiate()
		route_drawer.attach_to_car(c)
		route_drawer_container.add_child(route_drawer)
	
	change_active(0)

func is_finished() -> bool:
	return active_index >= cars.size()

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

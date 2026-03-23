extends Node2D
class_name Cars

@export var car_scene : PackedScene
var cars : Array[Car] = []
var active_index := -1

# @TODO: much longer list with more variation -> go through a ColorName enum again??
static var car_colors : Array[Color] = [Color.BLACK, Color.RED, Color.BLUE, Color.GREEN]
static func get_car_color(idx:int) -> Color:
	return car_colors[idx + 1]

func visualize(vis:PuzzleVisualizer) -> void:
	var gen := vis.generator
	for i in range(gen.count_cars()):
		var pos := vis.convert_cell_pos_to_real_pos(gen.car_starts[i].pos)
		var c := car_scene.instantiate()
		c.set_position(pos)
		add_child(c)
		c.set_color(get_car_color(i))
		cars.append(c)

func change_active(dc:int) -> void:
	active_index += dc

func get_active_index() -> int:
	return clampi(active_index, 0, cars.size() - 1)

func get_active_car() -> Car:
	return cars[get_active_index()]

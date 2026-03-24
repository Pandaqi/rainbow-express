extends PuzzleConnection
class_name Connection

var car_index := -1
var pickup_for := -1
var part_of_route : Array[int] = []

signal changed()

func has_pickup() -> bool:
	return pickup_for != -1

func register_car_visit(idx:int) -> void:
	part_of_route.append(idx)

func forget_car_visit(idx:int) -> void:
	part_of_route.erase(idx)

func was_visited_by(idx:int) -> bool:
	return part_of_route.has(idx)

func was_visited() -> bool:
	return part_of_route.size() > 0

func collect() -> void:
	pickup_for = -1
	changed.emit()

func uncollect(idx:int) -> void:
	pickup_for = idx
	changed.emit()

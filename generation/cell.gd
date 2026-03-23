extends PuzzleCell
class_name CellData

## Index of the CAR that starts here
var is_start_for := -1

## Index of the CAR for which this is the destination
var is_destination_for := -1

func get_cars_here() -> Array[int]:
	var car_indices : Array[int] = []
	for connection in connections:
		var idx := (connection as Connection).car_index
		if idx == -1: continue
		if car_indices.has(idx): continue
		car_indices.append(idx)
	return car_indices

func is_crossroads() -> bool:
	return get_cars_here().size() > 1

func mark_as_start(idx:int) -> void:
	is_start_for = idx

func is_start() -> bool:
	return is_start_for != -1

func mark_as_destination(idx:int) -> void:
	is_destination_for = idx

func is_destination() -> bool:
	return is_destination_for != -1

func get_car_index() -> int:
	if is_start(): return is_start_for
	if is_destination(): return is_destination_for
	return -1

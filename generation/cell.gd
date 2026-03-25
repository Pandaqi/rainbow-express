extends PuzzleCell
class_name CellData

## Index of the CAR that starts here
var is_start_for := -1

## Index of the CAR for which this is the destination
var is_destination_for := -1

## Indices of CARS that have been here during generation
var car_indices_seen : Array[int] = []

## Indices of CARS that have been here (during dynamic play, not generation)
var part_of_route : Array[int] = []

## Triggers when car reaches it (during dynamic play, not generation)
var destination_reached := false

func get_cars_here() -> Array[int]:
	var car_indices : Array[int] = []
	for connection in connections:
		var idx := (connection as Connection).car_index
		if idx == -1: continue
		if car_indices.has(idx): continue
		car_indices.append(idx)
	return car_indices

func mark_as_correct_route(idx:int) -> void:
	if car_indices_seen.has(idx): return
	car_indices_seen.append(idx)

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

func was_visited_by_car(idx:int) -> bool:
	return part_of_route.has(idx)

func register_car_visit(idx:int) -> void:
	part_of_route.append(idx)

# @NOTE: We want to erase the LAST occurring value; .erase() does the first one
func forget_car_visit(idx:int) -> void:
	for i in range(part_of_route.size()-1,-1,-1):
		if part_of_route[i] == idx:
			part_of_route.remove_at(i)
			return

func arrive(idx:int) -> void:
	if idx != is_destination_for: return
	destination_reached = true
	changed.emit()

func depart(idx:int) -> void:
	if idx != is_destination_for: return
	destination_reached = false
	changed.emit()

func has_been_reached() -> bool:
	return is_destination() and destination_reached

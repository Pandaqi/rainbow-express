extends PuzzleConnection
class_name Connection

var truck_index := -1
var pickup_for := -1

func has_pickup() -> bool:
	return pickup_for != -1

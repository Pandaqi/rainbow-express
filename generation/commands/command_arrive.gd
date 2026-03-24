extends PuzzleCommand
class_name CommandArrive

var car : Car

func _init(c:Car) -> void:
	car = c

func do(_cmds:PuzzleCommands) -> bool:
	car.arrive()
	var cars : Cars = car.get_parent() # @TODO: pass in directly, this is just for quick coding
	cars.change_active(+1)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	car.depart()
	var cars : Cars = car.get_parent() # @TODO: pass in directly, this is just for quick coding
	cars.change_active(-1)
	return true

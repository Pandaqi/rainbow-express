extends PuzzleCommand
class_name CommandArrive

var car : Car

func _init(c:Car) -> void:
	car = c

func do(_cmds:PuzzleCommands) -> bool:
	car.arrive()
	car.manager.change_active(+1)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	car.manager.change_active(-1)
	car.depart()
	return true

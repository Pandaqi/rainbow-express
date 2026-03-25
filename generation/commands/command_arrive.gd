extends PuzzleCommand
class_name CommandArrive

var car : Car

func _init(c:Car) -> void:
	car = c

func do(_cmds:PuzzleCommands) -> bool:
	car.arrive()
	car.manager.on_car_arrived(car)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	car.manager.on_car_departed(car)
	car.depart()
	return true

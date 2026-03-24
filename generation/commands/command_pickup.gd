extends PuzzleCommand
class_name CommandPickup

var car : Car
var connection : Connection

func _init(c:Car, co:Connection) -> void:
	car = c
	connection = co

func do(_cmds:PuzzleCommands) -> bool:
	car.change_pickups_collected(+1)
	connection.collect()
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	connection.uncollect(car.index)
	car.change_pickups_collected(-1)
	return true

extends PuzzleCommand
class_name CommandMove

var car : Car
var cell : Cell

func _init(c:Car, cd:Cell) -> void:
	car = c
	cell = cd

func do(cmds:PuzzleCommands) -> bool:
	var conn := car.get_current_cell().data.get_connection_to(cell.data) as Connection
	if conn and conn.pickup_for == car.index:
		cmds.execute_command(CommandPickup.new(car, conn))
	
	await car.set_grid_position(cell)
	
	# @TODO: give feedback when not all pickups collected, so player knows what's wrong
	if car.is_at_destination() and car.all_pickups_collected():
		cmds.execute_command(CommandArrive.new(car))
	
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	await car.unset_last_grid_position()
	return true

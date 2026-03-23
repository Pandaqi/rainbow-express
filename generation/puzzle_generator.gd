class_name PuzzleGenerator

var grid : PuzzleGrid

@export var grid_size := Vector2i(5,5)
@export var num_cars := 3
@export var route_length_bounds := Vector2i(7, 8)
@export var dist_between_pickups := Vector2i(2, 4)

var car_starts : Array[PuzzleCell]
var car_destinations : Array[PuzzleCell]
var car_routes : Array[Array]
var car_routes_connections : Array[Array]

func generate() -> void:
	create_grid()
	drive_cars()
	place_collectibles()
	clean_up()

func create_grid() -> void:
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.create(grid_size)

func drive_cars() -> void:
	car_starts = []
	car_destinations = []
	car_routes = []
	car_routes_connections = []
	
	for i in range(num_cars):
		drive_car()

func drive_car() -> void:
	var pathfinder := PathfinderRandom.new()
	var desired_length := randi_range(route_length_bounds.x, route_length_bounds.y)
	
	# only allow starting from cells that aren't another car's start
	# only allow from cells with at least one OPEN connection
	# @TODO: that first requirement can be loosened, it's actually fine if cars share a start/end!
	var cells_allowed := grid.get_cells().filter(func(c:PuzzleCell): 
		var claimed_by_other_car := (c as CellData).is_start() or (c as CellData).is_destination()
		var free_connections_left := c.count_connections() < 4
		return (not claimed_by_other_car) and free_connections_left
	)
	
	if cells_allowed.size() <= 0:
		print("PUZZLE GEN | Error | No possible starting space for car")
		return
	
	# keep trying shorter and shorter paths from every possible cell
	# we're guaranteed to find SOMETHING at some point
	var path : Array[PuzzleCell]
	while path.size() <= 0 and desired_length > 1:
		cells_allowed.shuffle()
		for cell in cells_allowed:
			path = pathfinder.find(cell, desired_length)
			if path.size() > 0: break
		desired_length -= 1
	
	if path.size() <= 0:
		print("PUZZLE GEN | Error | No possible path for car")
		return
	
	# save the end result
	car_starts.append(path.front())
	car_destinations.append(path.back())
	car_routes.append(path)
	
	# mark the edges used as connections
	var car_index := car_routes.size() - 1
	var connections : Array[Connection] = []
	for i in range(0, path.size() - 1):
		var a := path[i]
		var b := path[i+1]
		var connection := Connection.new(a,b)
		connection.car_index = car_index
		a.add_connection(connection)
		b.add_connection(connection)
		connections.append(connection)
	
	car_routes_connections.append(connections)

# go through entire car path, determine some positions for pickups + mark destination
func place_collectibles() -> void:
	for i in range(car_routes.size()):
		car_starts[i].mark_as_start(i)
		car_destinations[i].mark_as_destination(i)
		
		var next_pickup_index := randi_range(dist_between_pickups.x, dist_between_pickups.y)
		var route := car_routes_connections[i]
		for a in range(route.size()):
			if a != next_pickup_index: continue
			(route[a] as Connection).pickup_for = i
			next_pickup_index += randi_range(dist_between_pickups.x, dist_between_pickups.y)

# Add some random connections and connecting roads; especially if the cars don't cross anywhere yet
func clean_up() -> void:
	var crossroads := get_all_crossroads()
	var too_unconnected := crossroads.size() <= 0
	if too_unconnected:
		pass # @TODO
	
func get_all_crossroads() -> Array[PuzzleCell]:
	return grid.get_cells().filter(func(c:CellData): return c.is_crossroads())

func count_cars() -> int:
	return car_starts.size()

func debug_print_car_routes() -> void:
	for route in car_routes:
		var points := route.map(func(c:PuzzleCell): return c.pos)
		print(points)

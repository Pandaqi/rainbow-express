class_name PuzzleGenerator

var grid : PuzzleGrid

@export var grid_size := Vector2i(5,5)
@export var num_trucks := 3
@export var route_length_bounds := Vector2i(7, 8)
@export var dist_between_pickups := Vector2i(2, 4)

var truck_starts : Array[PuzzleCell]
var truck_destinations : Array[PuzzleCell]
var truck_routes : Array[Array]
var truck_routes_connections : Array[Array]

func generate() -> void:
	create_grid()
	drive_trucks()
	place_collectibles()
	clean_up()

func create_grid() -> void:
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.create(grid_size)

func drive_trucks() -> void:
	truck_starts = []
	truck_destinations = []
	truck_routes = []
	truck_routes_connections = []
	
	for i in range(num_trucks):
		drive_truck()

func drive_truck() -> void:
	var pathfinder := PathfinderRandom.new()
	var desired_length := randi_range(route_length_bounds.x, route_length_bounds.y)
	
	# only allow starting from cells that aren't another truck's start
	# only allow from cells with at least one OPEN connection
	# @TODO: that first requirement can be loosened, it's actually fine if trucks share a start/end!
	var cells_allowed := grid.get_cells().filter(func(c:PuzzleCell): 
		var claimed_by_other_truck := (c as CellData).is_start() or (c as CellData).is_destination()
		var free_connections_left := c.count_connections() < 4
		return (not claimed_by_other_truck) and free_connections_left
	)
	
	if cells_allowed.size() <= 0:
		print("PUZZLE GEN | Error | No possible starting space for truck")
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
		print("PUZZLE GEN | Error | No possible path for truck")
		return
	
	# save the end result
	truck_starts.append(path.front())
	truck_destinations.append(path.back())
	truck_routes.append(path)
	
	# mark the edges used as connections
	var truck_index := truck_routes.size() - 1
	var connections : Array[Connection] = []
	for i in range(0, path.size() - 1):
		var a := path[i]
		var b := path[i+1]
		var connection := Connection.new(a,b)
		connection.truck_index = truck_index
		a.add_connection(connection)
		b.add_connection(connection)
		connections.append(connection)
	
	truck_routes_connections.append(connections)

# go through entire truck path, determine some positions for pickups + mark destination
func place_collectibles() -> void:
	for i in range(truck_routes.size()):
		truck_starts[i].mark_as_start(i)
		truck_destinations[i].mark_as_destination(i)
		
		var next_pickup_index := randi_range(dist_between_pickups.x, dist_between_pickups.y)
		var route := truck_routes_connections[i]
		for a in range(route.size()):
			if a != next_pickup_index: continue
			(route[a] as Connection).pickup_for = i
			next_pickup_index += randi_range(dist_between_pickups.x, dist_between_pickups.y)

# Add some random connections and connecting roads; especially if the trucks don't cross anywhere yet
func clean_up() -> void:
	var crossroads := get_all_crossroads()
	var too_unconnected := crossroads.size() <= 0
	if too_unconnected:
		pass # @TODO
	
func get_all_crossroads() -> Array[PuzzleCell]:
	return grid.get_cells().filter(func(c:CellData): return c.is_crossroads())

func debug_print_truck_routes() -> void:
	for route in truck_routes:
		var points := route.map(func(c:PuzzleCell): return c.pos)
		print(points)

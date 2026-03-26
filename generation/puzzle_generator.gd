class_name PuzzleGenerator

var grid : PuzzleGrid

@export var grid_size := Vector2i(5,5)
@export var num_cars_bounds := Vector2i(2,3)
@export var route_length_bounds := Vector2i(7, 8)
@export var dist_between_pickups := Vector2i(4, 6)
@export var allow_collectibles := true

var fake_roads_to_map_edge_prob := 0.33

var car_starts : Array[PuzzleCell]
var car_destinations : Array[PuzzleCell]
var car_routes : Array[Array]
var car_routes_connections : Array[Array]
var car_num_pickups : Array[int]
var all_connections : Array[Connection]

var extra_connections : Dictionary[CellData, Array]

func generate() -> void:
	PuzzleSettings.apply_difficulty_properties(self)
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
	car_num_pickups = []
	
	var num_cars := randi_range(num_cars_bounds.x, num_cars_bounds.y)
	for i in range(num_cars):
		drive_car()

func drive_car() -> void:
	var pathfinder := PathfinderRandom.new()
	
	# don't allow ending at start/end point of another truck
	pathfinder.validity_callback = func(_a:CellData, b:CellData, length_remaining:int):
		if length_remaining > 0: return true
		if b.is_destination(): return false
		if b.is_start(): return false
		return true
	
	# we prefer going into neighbors with lots of connections to cause crossroads
	pathfinder.neighbors_callback = func(cell:CellData, length_remaining:int):
		var nbs := cell.get_neighbors_shuffled()
		nbs.sort_custom(func(a:CellData, b:CellData): 
			return a.count_connections() > b.count_connections()
		)
		return nbs
	
	var desired_length := randi_range(route_length_bounds.x, route_length_bounds.y)
	
	# only allow starting from cells that aren't another car's start
	# only allow from cells with at least one OPEN connection
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
	
	car_routes.append(path)
	
	# save the end result
	var car_index := car_routes.size() - 1
	
	for cell in path:
		(cell as CellData).mark_as_correct_route(car_index)
	
	car_starts.append(path.front())
	path.front().mark_as_start(car_index)

	car_destinations.append(path.back())
	path.back().mark_as_destination(car_index)
	
	# mark the edges used as connections
	var connections : Array[Connection] = []
	for i in range(0, path.size() - 1):
		var a := path[i]
		var b := path[i+1]
		var conn := connect_cells(car_index, a, b)
		connections.append(conn)
	
	all_connections += connections
	car_routes_connections.append(connections)

func connect_cells(car_index:int, a:CellData, b:CellData) -> Connection:
	if a.has_connection_to(b): return null
	if b.has_connection_to(a): return null
	
	var connection := Connection.new(a,b)
	connection.car_index = car_index
	a.add_connection(connection)
	b.add_connection(connection)
	return connection

# go through entire car path, determine some positions for pickups + mark destination
func place_collectibles() -> void:
	for i in range(car_routes.size()):
		if not allow_collectibles:
			car_num_pickups.append(0)
			continue
		
		var next_pickup_index := randi_range(dist_between_pickups.x, dist_between_pickups.y)
		var route := car_routes_connections[i]
		var total_num_pickups := 0
		for a in range(route.size()):
			if a != next_pickup_index: continue
			(route[a] as Connection).pickup_for = i
			total_num_pickups += 1
			next_pickup_index += randi_range(dist_between_pickups.x, dist_between_pickups.y)
		car_num_pickups.append(total_num_pickups)

func clean_up() -> void:
	
	# if we find a route unconnected to anything else
	# find any connection (along that route) that would attach it to a cell with a DIFFERENT car index
	clean_up_standalone_routes()
	
	# grab all possible extra connections we could make
	cache_possible_extra_connections()
	
	# use them to place some more connections
	ensure_map_balance()
	
	# if routes are connected AND we ensure map balance by adding longest leftout connections, we really don't need this anymore => besides, the `.is_crossroads()` call is a different definition than what I use in this function, so it's meh anyway
	#ensure_enough_crossroads()

func ensure_map_balance() -> void:
	var all_extra_paths := []
	for cell in extra_connections:
		all_extra_paths += extra_connections[cell]
	all_extra_paths.sort_custom(func(a,b): return a.size() > b.size())
	
	var long_stretch_length := 5 if grid_size.x > 6 else 4
	while all_extra_paths.size() > 0 and all_extra_paths.front().size() >= long_stretch_length:
		var path : Array[CellData] = all_extra_paths.pop_front()
		var goes_to_map_edge : bool = path.back().count_connections() <= 0
		if goes_to_map_edge and randf() > fake_roads_to_map_edge_prob: continue
		
		connect_cells_in_path(path)

func cache_possible_extra_connections():
	extra_connections = {}
	for cell in grid.get_cells():
		if cell.count_connections() <= 0: continue
		var extra_conns := get_all_extra_connections(cell)
		if extra_conns.size() <= 0: continue
		extra_connections[cell as CellData] = extra_conns 

func get_all_extra_connections(cell:CellData) -> Array:
	var dirs := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	var paths : Array = []
	for dir in dirs:
		var path := get_path_to_first_other_cell(-1, cell, dir)
		if path.size() <= 0: continue
		paths.append(path)
	
	return paths


func ensure_enough_crossroads() -> void:
	var crossroads := get_all_crossroads()
	var num_cars := count_cars()
	var crossroads_desired := (num_cars - 1)*2
	var num_crossroads := crossroads.size()
	var connected_enough := num_crossroads >= crossroads_desired
	if connected_enough: return
	
	var num_tries := 0
	var max_tries := 50
	while num_crossroads < crossroads_desired and num_tries < max_tries:
		num_tries += 1
		var rand_car := randi() % num_cars
		var rand_cell : CellData = car_routes[rand_car].pick_random()
		var result := connect_cell_into_crossroads(rand_cell)
		if result: num_crossroads += 1

func clean_up_standalone_routes() -> void:
	if count_cars() <= 1: return
	
	# check if a route is completely standalone
	# that is, it shares NO cell with another route
	# if so, MAKE it connected
	for i in range(car_routes.size()):
		var my_route := car_routes[i]
		var is_standalone := true
		
		for j in range(car_routes.size()):
			if i == j: continue
			var other_route := car_routes[j]
			for cell_data in my_route:
				if other_route.has(cell_data):
					is_standalone = false
					break
			if not is_standalone: break
		
		if not is_standalone: continue
		
		var my_route_shuffled = my_route.duplicate()
		var num_connections_desired := randi_range(2,2)
		var num_connections := 0
		my_route_shuffled.shuffle()
		for cell_data in my_route_shuffled:
			var result := connect_cell_straight(i, cell_data)
			if result: num_connections += 1
			if num_connections >= num_connections_desired: break

func get_extra_connection(cell_data:CellData, method := "random") -> Array[CellData]:
	if not (cell_data in extra_connections): return []
	
	var arr : Array[CellData] = []
	if method == "shortest":
		extra_connections[cell_data].sort_custom(func(a:Array[CellData], b:Array[CellData]): return a.size() < b.size())
	elif method == "longest":
		extra_connections[cell_data].sort_custom(func(a:Array[CellData], b:Array[CellData]): return a.size() > b.size())
	elif method == "random":
		extra_connections[cell_data].shuffle()
	
	arr.assign(extra_connections[cell_data].front())
	return arr

func connect_cells_in_path(path:Array) -> void:
	for i in range(path.size() - 1):
		connect_cells(-1, path[i], path[i+1])

func get_path_to_first_other_cell(car_index:int, cell:CellData, dir:Vector2i) -> Array[CellData]:
	var current_cell := cell
	var path : Array[CellData] = [current_cell]
	while current_cell:
		var new_pos := current_cell.pos + dir
		
		# stop if there's nothing here
		if grid.is_out_of_bounds(new_pos): 
			current_cell = null
			break
		
		# save new cell
		current_cell = grid.get_at(new_pos)
		path.append(current_cell)
		
		# if it has connections, either stop the path if it's another car
		# OR stop and CLEAR if it's only ourselves, as this is a dead end we don't want to connect to
		if current_cell.count_connections() > 0:
			# check if it has seen a car that's not our own => then it must be a new/other connection
			var not_part_of_any_route := (current_cell.car_indices_seen.size() <= 0)
			var is_other := current_cell.car_indices_seen.find_custom(func(idx): return idx != car_index) != -1
			if car_index == -1: is_other = true
			if not is_other: path = []
			break

	return path

func connect_cell_straight(car_index:int, cell:CellData) -> bool:
	var dirs := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	dirs.shuffle()
	
	# try directions in random order
	for dir in dirs:
		
		# if we find something to connect to ...
		var path := get_path_to_first_other_cell(car_index, cell, dir)
		if path.size() <= 0: continue
		
		# ... do so and stop looking
		for i in range(path.size() - 1):
			connect_cells(-1, path[i], path[i+1])
		break
	
	return false

func connect_cell_into_crossroads(cell:CellData) -> bool:
	for nb in cell.get_neighbors():
		if not cell.has_connection_to(nb):
			connect_cells(-1, cell, nb)
	return true

func get_all_crossroads() -> Array[PuzzleCell]:
	return grid.get_cells().filter(func(c:CellData): return c.is_crossroads())

func count_cars() -> int:
	return car_starts.size()

func debug_print_car_routes() -> void:
	for route in car_routes:
		var points := route.map(func(c:PuzzleCell): return c.pos)
		print(points)

func get_connection_between_positions(from_pos:Vector2i, to_pos:Vector2i) -> Connection:
	var cell1 := grid.get_at(from_pos)
	var cell2 := grid.get_at(to_pos)
	return cell1.get_connection_to(cell2)

func connection_exists_between(from_pos:Vector2i, to_pos:Vector2i) -> bool:
	return get_connection_between_positions(from_pos, to_pos) != null

func overlaps_used_connection(from_pos:Vector2i, to_pos:Vector2i) -> bool:
	var conn := get_connection_between_positions(from_pos, to_pos)
	
	# if this connection does not exist, then we're always fine
	if not conn: return false
	
	# otherwise, check if ANY car used this connection for whatever reason
	if conn.was_visited(): return true
	
	return false

func get_solution(vis:PuzzleVisualizer) -> Array[PuzzleCommand]:
	var arr : Array[PuzzleCommand] = []
	for c in range(count_cars()):
		var car : Car = vis.cars.cars[c]
		var route := car_routes[c]
		for p in range(1, route.size()):
			var cell := vis.get_cell_for_data(route[p])
			arr.append(CommandMove.new(car, cell))
	return arr

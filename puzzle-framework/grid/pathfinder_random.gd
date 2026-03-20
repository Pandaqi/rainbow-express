class_name PathfinderRandom

var cells_visited : Array[PuzzleCell]
var avoid_touching := false
var path : Array[PuzzleCell]

func is_valid() -> bool:
	return path.size() > 0

func is_already_visited(c:PuzzleCell) -> bool:
	return cells_visited.has(c)

func mark_visited(c:PuzzleCell) -> void:
	cells_visited.append(c)

func mark_unvisited(c:PuzzleCell) -> void:
	cells_visited.erase(c)

func find(start_cell:PuzzleCell, path_length:int) -> Array[PuzzleCell]:
	cells_visited = [start_cell]
	path = []
	
	for nb in start_cell.get_neighbors_shuffled():
		var potential_path := extend_path(path_length, start_cell, nb)
		if potential_path.size() <= 0: continue
		
		potential_path.append(nb)
		path = potential_path
		break
	
	if path.size() <= 0: return []
	
	path.append(start_cell)
	path.reverse()
	
	return path

func extend_path(remaining_length:int, cell_start: PuzzleCell, cell_end: PuzzleCell) -> Array[PuzzleCell]:
	if is_already_visited(cell_end): return []
	if cell_start.has_connection_to(cell_end): return []
	
	# avoid touching already visited squares (if we're grid-based, not graph-based)
	if avoid_touching:
		for nb in cell_end.get_neighbors():
			if nb == cell_start: continue
			if is_already_visited(nb): return []
	
	# visit the cell
	mark_visited(cell_end)
	
	# if we're done, start a new path with this end point
	if remaining_length <= 0: return [cell_end]
	
	# otherwise, keep searching/recursing deeper
	for nb in cell_end.get_neighbors_shuffled():
		var path_extended := extend_path(remaining_length - 1, cell_end, nb)
		if path_extended.size() <= 0: continue
		
		# because our terminating function returns `[cell_end]`, we don't need to add the point again
		if remaining_length > 1: path_extended.append(nb)
		return path_extended
	
	# if we haven't returned by now, then no path worked out for us
	mark_unvisited(cell_end)
	return []

extends Node2D
class_name Collectibles

@export var collectible_scene : PackedScene
var connection_to_collectible : Dictionary[Connection, Collectible] = {}

func visualize(vis:PuzzleVisualizer) -> void:
	var all_cells := vis.generator.grid.get_cells()
	for cell_data in all_cells:
		# display connections; cells are responsible for the connection to their right or down
		# (to prevent two cells both drawing the same connection)
		for connected_cell in cell_data.connection_cells:
			var connection := cell_data.connection_cells[connected_cell] as Connection
			if not connection.has_pickup(): continue
			
			var dir := connected_cell.pos - cell_data.pos
			var is_right_or_down := dir.x > 0 or dir.y > 0
			if not is_right_or_down: continue
			
			var pos := vis.convert_cell_pos_to_real_pos(cell_data.pos) + dir * 0.5 * vis.cell_size
			
			var col : Collectible = collectible_scene.instantiate()
			col.sync_data(connection)
			col.set_position(pos)
			add_child(col)
			connection_to_collectible[connection] = col
